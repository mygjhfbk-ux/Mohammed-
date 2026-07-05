<?php
/**
 * api/update_ad_status.php
 * تغيير حالة العرض (تفعيل/��يقاف) للإعلان
 * body: ad_id, is_active (0/1)
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') sendResponse('error','Method not allowed',null,405);
$user = authenticate();
if ($user['User-type'] !== 'admin') sendResponse('error','ممنوع',null,403);

$data = getRequestData();
$adId = $data['ad_id'] ?? null;
$active = isset($data['is_active']) ? (int)$data['is_active'] : null;
if (!$adId || $active === null) sendResponse('error','بيانات ناقصة',null,400);

try {
    $pdo = getPDO();
    $stmt = $pdo->prepare("UPDATE ads SET is_active = ?, updated_at = NOW() WHERE ad_id = ?");
    $stmt->execute([$active, $adId]);
    sendResponse('success','تم تحديث حالة الإعلان');
} catch (Exception $e) {
    api_log('update_ad_status error: '.$e->getMessage());
    sendResponse('error','Server error',null,500);
}
