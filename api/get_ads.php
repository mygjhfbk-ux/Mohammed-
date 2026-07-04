<?php
/**
 * api/get_ads.php
 * جلب الإعلانات النشطة (لا يتطلب توثيق عادة)
 */

require_once __DIR__ . '/../config/db.php';

try {
    $pdo = getPDO();
    $query = "SELECT ad_id, ad_title, ad_image, ad_link, ad_type FROM ads WHERE is_active = 1 AND (start_date <= CURDATE() OR start_date IS NULL) AND (end_date >= CURDATE() OR end_date IS NULL) ORDER BY created_at DESC";
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $ads = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $base = (getenv('UPLOAD_BASE_URL') ?: '/uploads/ads/');
    foreach ($ads as &$ad) {
        $ad['ad_image'] = $base . $ad['ad_image'];
    }

    sendResponse('success', 'Ads fetched', $ads);
} catch (Exception $e) {
    api_log('get_ads error: ' . $e->getMessage());
    sendResponse('error', 'Server error', null, 500);
}
