<?php
/**
 * api/mark_notifications_read.php
 * تعليم كل الإشعارات كمقروءة ل��مستخدم الحالي
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

$user = authenticate();
try {
    $pdo = getPDO();
    $stmt = $pdo->prepare("UPDATE `notifications` SET `Not-isread` = 1, `updated_at` = NOW() WHERE `Receiver-id` = ? AND `Not-isread` = 0");
    $stmt->execute([$user['User-id']]);
    sendResponse('success', 'تم تحديث حالة الإشعارات');
} catch (Exception $e) {
    api_log('mark_notifications_read error: ' . $e->getMessage());
    sendResponse('error', 'فشل التحديث: ' . $e->getMessage(), null, 500);
}
