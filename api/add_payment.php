<?php
/**
 * api/add_payment.php
 * يضيف سداداً (payment) لطلب معين. مخصص للتاجر.
 * body: request_id, amount, description (اختياري)
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse('error', 'Method not allowed', null, 405);
}

$user = authenticate();
if ($user['User-type'] !== 'merchant') {
    sendResponse('error', 'مسموح للتجار فقط', null, 403);
}

$data = getRequestData();
$requestId = $data['request_id'] ?? null;
$amount = isset($data['amount']) ? (float)$data['amount'] : null;
$description = $data['description'] ?? 'سداد مبلغ نقدي';

if (!$requestId || !$amount || $amount <= 0) {
    sendResponse('error', 'بيانات الطلب ناقصة أو المبلغ غير صالح', null, 400);
}

try {
    $pdo = getPDO();
    $stmtM = $pdo->prepare("SELECT `Merchant-id` FROM merchants WHERE `User-id` = ? LIMIT 1");
    $stmtM->execute([$user['User-id']]);
    $merchant = $stmtM->fetch(PDO::FETCH_ASSOC);
    if (!$merchant) sendResponse('error', 'بيانات التاجر غير مكتملة', null, 403);
    $merchantId = $merchant['Merchant-id'];

    $pdo->beginTransaction();

    $stmtLast = $pdo->prepare("SELECT Balance_After FROM transactions WHERE `Request-id` = ? ORDER BY `Transaction-id` DESC LIMIT 1 FOR UPDATE");
    $stmtLast->execute([$requestId]);
    $lastBal = $stmtLast->fetchColumn();
    $lastBal = $lastBal !== false ? (float)$lastBal : 0.00;
    $newBalance = $lastBal - $amount;

    $stmtIns = $pdo->prepare("INSERT INTO transactions (`Merchant-id`,`Request-id`,`Amount`,`Debit`,`Credit`,`Balance_After`,`Transaction-type`,`Description`,`Transaction-Date`,`created_at`) VALUES (?, ?, ?, 0.00, ?, ?, 'payment', ?, NOW(), NOW())");
    $stmtIns->execute([$merchantId, $requestId, $amount, $amount, $newBalance, $description]);
    $transactionId = $pdo->lastInsertId();

    // تحديث total_debt (نقصان)
    $stmtUpd = $pdo->prepare("UPDATE requests SET total_debt = total_debt - ? WHERE `Request-id` = ?");
    $stmtUpd->execute([$amount, $requestId]);

    // إرسال إشعار للعميل إن وُجد
    $stmtReq = $pdo->prepare("SELECT `Customer-id` FROM requests WHERE `Request-id` = ? LIMIT 1");
    $stmtReq->execute([$requestId]);
    $custId = $stmtReq->fetchColumn();
    if ($custId) {
        $stmtC = $pdo->prepare("SELECT `User-id` FROM customers WHERE `Customer-id` = ? LIMIT 1");
        $stmtC->execute([$custId]);
        $custUserId = $stmtC->fetchColumn();
        if ($custUserId) {
            $stmtNot = $pdo->prepare("INSERT INTO notifications (`Sender-id`,`Receiver-id`,`Not-content`,`Not-isread`,`created_at`) VALUES (?, ?, ?, 0, NOW())");
            $content = "تم استلام مبلغ سداد بقيمة " . number_format($amount,2);
            $stmtNot->execute([$merchantId, $custUserId, $content]);
        }
    }

    $pdo->commit();
    sendResponse('success', 'تم السداد بنجاح', ['transaction_id' => $transactionId, 'balance_after' => $newBalance]);

} catch (Exception $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    api_log('add_payment error: ' . $e->getMessage());
    sendResponse('error', 'فشل السداد: ' . $e->getMessage(), null, 500);
}
