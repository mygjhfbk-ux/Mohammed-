<?php
/**
 * api/update_full_customer.php
 * تحديث بيانات العميل (مخصص admin أو merchant في حال is_local = 0)
 * body: customer_id, fields...
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') sendResponse('error','Method not allowed',null,405);
$user = authenticate();
$data = getRequestData();
$customerId = $data['customer_id'] ?? null;
if (!$customerId) sendResponse('error','Customer id required',null,400);

try {
    $pdo = getPDO();
    // صلا��ية: admin أو التاجر الذي يملك العلاقة
    if ($user['User-type'] === 'merchant') {
        // تحقق من وجود علاقة
        $stmt = $pdo->prepare("SELECT * FROM requests WHERE `Customer-id` = ? AND `Merchant-id` IN (SELECT `Merchant-id` FROM merchants WHERE `User-id` = ?) LIMIT 1");
        $stmt->execute([$customerId, $user['User-id']]);
        if (!$stmt->fetch()) sendResponse('error','غير مسموح',null,403);
    }

    $fields = [];
    $params = [];
    $allowed = ['Customer-Name','Customer-address'];
    foreach ($allowed as $f) {
        if (isset($data[$f])) { $fields[] = "`$f` = ?"; $params[] = $data[$f]; }
    }
    if (empty($fields)) sendResponse('error','لا توجد حقول لتحديثها',null,400);
    $params[] = $customerId;
    $sql = "UPDATE customers SET " . implode(', ', $fields) . ", updated_at = NOW() WHERE `Customer-id` = ?";
    $stmtUpd = $pdo->prepare($sql);
    $stmtUpd->execute($params);
    sendResponse('success','تم تحديث بيانات العميل');
} catch (Exception $e) {
    api_log('update_full_customer error: '.$e->getMessage());
    sendResponse('error','Server error',null,500);
}
