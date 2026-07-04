<?php
/**
 * api/update_transaction.php
 * تعديل عملية دين أو قبض (يعدّل المبلغ ويصحّح الأرصدة اللاحقة)
 * body: transaction_id, amount, description (اختياري), items (تفاصيل جديدة)
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
$description = $data['description'] ?? 'تعديل دين';
$items = $data['items'] ?? [];

if (!$transactionId || !$newAmount) sendResponse('error', 'بيانات التعديل ناقصة', null, 400);

try {
    $pdo = getPDO();
    $pdo->beginTransaction();

    // جلب العملية والربط بالـ Request
    $stmt = $pdo->prepare("SELECT t.*, r.`Request-id` as req_id FROM transactions t JOIN requests r ON t.`Request-id` = r.`Request-id` WHERE t.`Transaction-id` = ? FOR UPDATE");
    $stmt->execute([$transactionId]);
    $old = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$old) {
        $pdo->rollBack();
        sendResponse('error', 'العملية غير موجودة', null, 404);
    }

    $requestId = $old['Request-id'];
    $oldAmount = (float)$old['Amount'];
    $type = $old['Transaction-type'];

    $diff = $newAmount - $oldAmount; // تأثير على total_debt و balance

    // تحديث العملية
    $stmtUp = $pdo->prepare("UPDATE transactions SET `Amount` = ?, `Debit` = ?, `Credit` = ?, `Description` = ?, `updated_at` = NOW() WHERE `Transaction-id` = ?");
    // افتراض: بالنسبة للديون (debt) نحط Debit = amount, Credit = 0; بالنسبة للسداد (payment) العكس
    if ($type === 'debt') {
        $debit = $newAmount; $credit = 0.00;
    } else {
        $debit = 0.00; $credit = $newAmount;
    }
    $stmtUp->execute([$newAmount, $debit, $credit, $description, $transactionId]);

    // تحديث transaction_details: حذف القديم وإضافة الجديد
    $stmtDel = $pdo->prepare("DELETE FROM transaction_details WHERE `Transaction-id` = ?");
    $stmtDel->execute([$transactionId]);
    if (!empty($items) && is_array($items)) {
        $stmtInsD = $pdo->prepare("INSERT INTO transaction_details (`Transaction-id`,`Item-Name`,`Quantity`,`Price`) VALUES (?, ?, ?, ?)");
        foreach ($items as $it) {
            $stmtInsD->execute([$transactionId, $it['name'] ?? '', $it['qty'] ?? 1, $it['price'] ?? 0]);
        }
    }

    // تحديث total_debt في requests (يعتمد على نوع العملية)
    if ($type === 'debt') {
        $stmtReq = $pdo->prepare("UPDATE requests SET total_debt = total_debt + ? WHERE `Request-id` = ?");
        $stmtReq->execute([$diff, $requestId]);
    } elseif ($type === 'payment') {
        // إذا كان سداداً، فإن الفرق الجديد يقلل أو يزيد الدين عكسياً
        $stmtReq = $pdo->prepare("UPDATE requests SET total_debt = total_debt - ? WHERE `Request-id` = ?");
        $stmtReq->execute([$diff, $requestId]);
    }

    // تصحيح Balance_After لكل المعاملات اللاحقة
    $stmtFix = $pdo->prepare("UPDATE transactions SET Balance_After = Balance_After + ? WHERE `Request-id` = ? AND `Transaction-id` >= ?");
    // ملاحظة: علامة diff على الصواب حسب تعريفنا أعلاه
    $stmtFix->execute([$diff, $requestId, $transactionId]);

    // إشعار ذكي
    // جلب User-id للعميل
    $stmtC = $pdo->prepare("SELECT r.`Customer-id`, c.`User-id` FROM requests r LEFT JOIN customers c ON r.`Customer-id` = c.`Customer-id` WHERE r.`Request-id` = ? LIMIT 1");
    $stmtC->execute([$requestId]);
    $info = $stmtC->fetch(PDO::FETCH_ASSOC);
    if ($info && $info['User-id']) {
        $stmtNot = $pdo->prepare("INSERT INTO notifications (`Sender-id`,`Receiver-id`,`Not-content`,`Not-isread`,`created_at`) VALUES (?, ?, ?, 0, NOW())");
        $statusText = ($diff > 0) ? 'زيادة' : 'تخفيض';
        $stmtNot->execute([$info['User-id'], $info['User-id'], "تنبيه: تم تعديل عملية. المبلغ الجديد: " . number_format($newAmount,2) . " (تم $statusText بمقدار " . number_format(abs($diff),2) . ")"]);
    }

    $pdo->commit();
    sendResponse('success', 'تم تعديل العملية بنجاح');

} catch (Exception $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    api_log('update_transaction error: ' . $e->getMessage());
    sendResponse('error', 'فشل التعديل: ' . $e->getMessage(), null, 500);
}
