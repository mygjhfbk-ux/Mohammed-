<?php
/**
 * api/delete_transaction.php
 * حذف عملية وتحديث إجمالي الدين (مخصص للتاجر)
 * body: transaction_id
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
if (!$transactionId) sendResponse('error', 'معرف الحركة مطلوب', null, 400);

try {
    $pdo = getPDO();
    $pdo->beginTransaction();

    $stmt = $pdo->prepare("SELECT `Request-id`, `Amount`, `Transaction-type` FROM transactions WHERE `Transaction-id` = ? FOR UPDATE");
    $stmt->execute([$transactionId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) {
        $pdo->rollBack();
        sendResponse('error', 'الحركة غير موجودة', null, 404);
    }

    $requestId = $row['Request-id'];
    $amount = (float)$row['Amount'];
    $type = $row['Transaction-type'];

    // حذف التفاصيل إن وُجدت
    $stmtDelDet = $pdo->prepare("DELETE FROM transaction_details WHERE `Transaction-id` = ?");
    $stmtDelDet->execute([$transactionId]);

    // حذف العملية
    $stmtDel = $pdo->prepare("DELETE FROM transactions WHERE `Transaction-id` = ?");
    $stmtDel->execute([$transactionId]);

    // تحديث total_debt حسب نوعها
    if ($type === 'debt' || $type === 'purchase') {
        $stmtUpd = $pdo->prepare("UPDATE requests SET total_debt = total_debt - ? WHERE `Request-id` = ?");
        $stmtUpd->execute([$amount, $requestId]);
    } else if ($type === 'payment') {
        $stmtUpd = $pdo->prepare("UPDATE requests SET total_debt = total_debt + ? WHERE `Request-id` = ?");
        $stmtUpd->execute([$amount, $requestId]);
    }

    // إعادة حساب الأرصدة التراكمية من نقطة الطلب إن أمكن (بسيط: نعكس التغيير على كل العمليات اللاحقة)
    $stmtFix = $pdo->prepare("UPDATE transactions SET Balance_After = Balance_After - ? WHERE `Request-id` = ? AND `Transaction-id` > ?");
    $stmtFix->execute([$amount, $requestId, $transactionId]);

    $pdo->commit();
    sendResponse('success', 'تم حذف الحركة وتحديث الرصيد بنجاح');

} catch (Exception $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    api_log('delete_transaction error: ' . $e->getMessage());
    sendResponse('error', 'فشل الحذف: ' . $e->getMessage(), null, 500);
}
