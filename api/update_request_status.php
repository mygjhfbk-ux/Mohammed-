<?php
/**
 * api/update_request_status.php
 * تغيير حالة الطلب: قبول/رفض/تجميد/إعادة تفعيل
 * body: request_id, status (0/1/2 etc)
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') sendResponse('error','Method not allowed',null,405);
$user = authenticate();

$data = getRequestData();
$requestId = $data['request_id'] ?? null;
$status = isset($data['status']) ? (int)$data['status'] : null;
if (!$requestId || $status === null) sendResponse('error','بيانات ناقصة',null,400);

try {
    $pdo = getPDO();
    // تأكد الملكية للتاجر
    if ($user['User-type'] === 'merchant') {
        $stmtM = $pdo->prepare("SELECT m.`Merchant-id` FROM merchants m WHERE m.`User-id` = ? LIMIT 1");
        $stmtM->execute([$user['User-id']]);
        $m = $stmtM->fetch(PDO::FETCH_ASSOC);
        if (!$m) sendResponse('error','بيانات التاجر غير موجودة',null,403);
        $merchantId = $m['Merchant-id'];
        $stmtChk = $pdo->prepare("SELECT * FROM requests WHERE `Request-id` = ? AND `Merchant-id` = ? LIMIT 1");
        $stmtChk->execute([$requestId, $merchantId]);
        if (!$stmtChk->fetch()) sendResponse('error','الطلب غير موجود أو ليس لك',null,404);
    }

    $stmtUpd = $pdo->prepare("UPDATE requests SET `Request-status` = ?, `updated_at` = NOW() WHERE `Request-id` = ?");
    $stmtUpd->execute([$status, $requestId]);
    sendResponse('success','تم تحديث حالة الطلب');
} catch (Exception $e) {
    api_log('update_request_status error: '.$e->getMessage());
    sendResponse('error','Server error',null,500);
}
