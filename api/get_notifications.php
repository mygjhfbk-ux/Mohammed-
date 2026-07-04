<?php
/**
 * api/get_notifications.php
 * إحضار الإشعارات لمستخدم محمي
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

$user = authenticate();
try {
    $pdo = getPDO();
    $stmt = $pdo->prepare("SELECT * FROM notifications WHERE `Receiver-id` = ? ORDER BY created_at DESC LIMIT 100");
    $stmt->execute([$user['User-id']]);
    $notes = $stmt->fetchAll(PDO::FETCH_ASSOC);
    sendResponse('success', 'Notifications fetched', $notes);
} catch (Exception $e) {
    api_log('notifications error: ' . $e->getMessage());
    sendResponse('error', 'Server error', null, 500);
}
