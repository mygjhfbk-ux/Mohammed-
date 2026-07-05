<?php
/**
 * api/update_ad_clicks.php
 * زيادة عداد النقرات للإعلان
 * body: ad_id
 */

require_once __DIR__ . '/../config/db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') sendResponse('error','Method not allowed',null,405);
$data = getRequestData();
$adId = $data['ad_id'] ?? null;
if (!$adId) sendResponse('error','ad_id required',null,400);

try {
    $pdo = getPDO();
    $stmt = $pdo->prepare("UPDATE ads SET click_count = click_count + 1 WHERE ad_id = ?");
    $stmt->execute([$adId]);
    sendResponse('success','Click recorded');
} catch (Exception $e) {
    api_log('update_ad_clicks error: '.$e->getMessage());
    sendResponse('error','Server error',null,500);
}
