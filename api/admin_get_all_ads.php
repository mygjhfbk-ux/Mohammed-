<?php
/**
 * api/admin_get_all_ads.php
 * جلب كل الإعلانات (محمية بالـ admin)
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

$user = authenticate();
if ($user['User-type'] !== 'admin') sendResponse('error', 'ممنوع', null, 403);

try {
    $pdo = getPDO();
    $stmt = $pdo->query("SELECT * FROM ads ORDER BY created_at DESC");
    $ads = $stmt->fetchAll(PDO::FETCH_ASSOC);
    sendResponse('success', 'Ads fetched', $ads);
} catch (Exception $e) {
    api_log('admin_get_all_ads error: ' . $e->getMessage());
    sendResponse('error', 'Server error', null, 500);
}
