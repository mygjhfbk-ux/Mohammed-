<?php
/**
 * api/add_debt.php
 * يضيف ديناً (credit/debt) لطلب معين. يقتصر على مستخدمي النوع merchant.
 * متطلبات body: request_id, amount, description (اختياري), items (اختياري array)
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';
require_once __DIR__ . '/../utils/send_otp.php';

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
$description = $data['description'] ?? 'تسجيل دين';
$items = $data['items'] ?? [];

if (!$requestId || !$amount || $amount <= 0) {
    sendResponse('error', 'بيانات الطلب ناقصة أو المبلغ غير صال��', null, 400);
}

try {
    $pdo = getPDO();
    // احصل على Merchant-id الخاص بالمستخدم المصرح
    $stmtM = $pdo->prepare("SELECT `Merchant-id` FROM merchants WHERE `User-id` = ? LIMIT 1");
    $stmtM->execute([$user['User-id']]);
    $merchant = $stmtM->fetch(PDO::FETCH_ASSOC);
    if (!$merchant) sendResponse('error', 'بيانات التاجر غير مكتملة', null, 403);
    $merchantId = $merchant['Merchant-id'];

    $pdo->beginTransaction();

    // قفل صف الطلب
    $stmtCheck = $pdo->prepare("SELECT total_debt, account_limit, is_active, `Customer-id` FROM requests WHERE `Request-id` = ? FOR UPDATE");
    $stmtCheck->execute([$requestId]);
    $req = $stmtCheck->fetch(PDO::FETCH_ASSOC);
    if (!$req) {
        $pdo->rollBack();
        sendResponse('error', 'طلب الربط غير موجود', null, 404);
    }

    if ((int)$req['is_active'] === 0) {
        $pdo->rollBack();
        sendResponse('error', 'هذا الحساب موقوف لا يمكن إضافة دين', null, 403);
    }

    $currentTotal = (float)$req['total_debt'];
    $limit = (float)$req['account_limit'];
    if ($limit > 0 && ($currentTotal + $amount) > $limit) {
        $pdo->rollBack();
        sendResponse('error', "سيتم تجاوز سقف الدين المسموح به لهذا العميل. السقف: $limit", null, 422);
    }

    // جلب آخر رصيد
    $stmtLast = $pdo->prepare("SELECT Balance_After FROM transactions WHERE `Request-id` = ? ORDER BY `Transaction-id` DESC LIMIT 1");
    $stmtLast->execute([$requestId]);
    $lastBal = $stmtLast->fetchColumn();
    $lastBal = $lastBal !== false ? (float)$lastBal : 0.00;
    $newBalance = $lastBal + $amount;

    // إدخال ترانزاكشن
    $stmtIns = $pdo->prepare("INSERT INTO transactions (`Merchant-id`,`Request-id`,`Amount`,`Debit`,`Credit`,`Balance_After`,`Transaction-type`,`Description`,`Transaction-Date`,`created_at`) VALUES (?, ?, ?, ?, 0.00, ?, 'debt', ?, NOW(), NOW())");
    $stmtIns->execute([$merchantId, $requestId, $amount, $amount, $newBalance, $description]);
    $transactionId = $pdo->lastInsertId();

    // تفاصيل الأصناف
    if (!empty($items) && is_array($items)) {
        $stmtDet = $pdo->prepare("INSERT INTO transaction_details (`Transaction-id`,`Item-Name`,`Quantity`,`Price`) VALUES (?, ?, ?, ?)");
        foreach ($items as $it) {
            $name = $it['name'] ?? '';
            $qty = isset($it['qty']) ? (float)$it['qty'] : 1;
            $price = isset($it['price']) ? (float)$it['price'] : 0;
            $stmtDet->execute([$transactionId, $name, $qty, $price]);
        }
    }

    // تحديث total_debt
    $stmtUpd = $pdo->prepare("UPDATE requests SET total_debt = total_debt + ? WHERE `Request-id` = ?");
    $stmtUpd->execute([$amount, $requestId]);

    // إرسال إشعار إذا كان هناك Customer-id مرتبط
    $customerId = $req['Customer-id'] ?? 0;
    if ($customerId && $customerId != 0) {
        // جلب User-id للعميل
        $stmtC = $pdo->prepare("SELECT `User-id` FROM customers WHERE `Customer-id` = ? LIMIT 1");
        $stmtC->execute([$customerId]);
        $custUserId = $stmtC->fetchColumn();
        if ($custUserId) {
            // إضافة إشعار
            $stmtNot = $pdo->prepare("INSERT INTO notifications (`Sender-id`,`Receiver-id`,`Not-content`,`Not-isread`,`created_at`) VALUES (?, ?, ?, 0, NOW())");
            $content = "تم إضافة دين جديد بمبلغ " . number_format($amount,2);
            $stmtNot->execute([$merchantId, $custUserId, $content]);
        }
    }

    $pdo->commit();
    sendResponse('success', 'تم تسجيل ��لدين بنجاح', ['transaction_id' => $transactionId, 'balance_after' => $newBalance]);

} catch (Exception $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    api_log('add_debt error: ' . $e->getMessage());
    sendResponse('error', 'فشل النظام: ' . $e->getMessage(), null, 500);
}
