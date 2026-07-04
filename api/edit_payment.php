<?php
/**
 * api/edit_payment.php
 * تعديل عملية سداد (payment)
 * body: transaction_id, amount, description (اختياري)
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
$transactionId = $data['transaction_id'] ?? null;
$newAmount = isset($data['amount']) ? (float)$data['amount'] : null;
$description = $data['description'] ?? 'تعديل سداد نقدي';

if (!$transactionId || !$newAmount) {
    sendResponse('error', 'بيانات التعديل ناقصة', null, 400);
}

try {
    $pdo = getPDO();
    $pdo->beginTransaction();

    // جلب العملية والبيانات المرتبطة
    $stmt = $pdo->prepare("SELECT t.`Transaction-id`, t.`Amount`, t.`Request-id`, r.`is_local`, c.`User-id` as customer_user_id, m.`User-id` as merchant_user_id FROM transactions t JOIN requests r ON t.`Request-id` = r.`Request-id` JOIN merchants m ON r.`Merchant-id` = m.`Merchant-id` LEFT JOIN customers c ON r.`Customer-id` = c.`Customer-id` WHERE t.`Transaction-id` = ? FOR UPDATE");
    $stmt->execute([$transactionId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) {
        $pdo->rollBack();
        sendResponse('error', 'العملية غير موجودة', null, 404);
    }

    $oldAmount = (float)$row['Amount'];
    $requestId = $row['Request-id'];
    $isLocal = (int)$row['is_local'];
    $receiverUserId = $row['customer_user_id'];
    $senderUserId = $row['merchant_user_id'];

    $diff = $oldAmount - $newAmount; // لأن السداد يقلل الدين

    // تحديث العملية
    $stmtUp = $pdo->prepare("UPDATE transactions SET `Amount` = ?, `Credit` = ?, `Description` = ?, `updated_at` = NOW() WHERE `Transaction-id` = ?");
    $stmtUp->execute([$newAmount, $newAmount, $description, $transactionId]);

    // تحديث total_debt (نضيف الفرق لأن diff = old - new)
    $stmtReq = $pdo->prepare("UPDATE requests SET total_debt = total_debt + ? WHERE `Request-id` = ?");
    $stmtReq->execute([$diff, $requestId]);

    // تعديل أرصدة لاحقة
    $stmtFix = $pdo->prepare("UPDATE transactions SET Balance_After = Balance_After + ? WHERE `Request-id` = ? AND `Transaction-id` >= ?");
    $stmtFix->execute([$diff, $requestId, $transactionId]);

    // إشعار ذكي
    if ($isLocal == 0 && !empty($receiverUserId)) {
        $notContent = "تم تعديل مبلغ سداد سابق. المبلغ الجديد: " . number_format($newAmount, 2);
        $stmtNot = $pdo->prepare("INSERT INTO notifications (`Sender-id`,`Receiver-id`,`Not-content`,`Not-isread`,`created_at`) VALUES (?, ?, ?, 0, NOW())");
        $stmtNot->execute([$senderUserId, $receiverUserId, $notContent]);
    }

    $pdo->commit();
    sendResponse('success', 'تم تعديل السداد وتصحيح الأرصدة بنجاح');

} catch (Exception $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    api_log('edit_payment error: ' . $e->getMessage());
    sendResponse('error', 'فشل التعديل: ' . $e->getMessage(), null, 500);
}
