<?php
/**
 * api/mark_single_notification_read.php
 * تعليم إشعار واحد كمقروء
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

$user = authenticate();
$data = getRequestData();
$notId = $data['not_id'] ?? null;
if (!$notId) sendResponse('error', 'معرف الإشعار مفقود', null, 400);

try {
    $pdo = getPDO();
    $stmt = $pdo->prepare("UPDATE `notifications` SET `Not-isread` = 1, `updated_at` = NOW() WHERE `Not-id` = ? AND `Receiver-id` = ?");
    $stmt->execute([$notId, $user['User-id']]);
    if ($stmt->rowCount() > 0) sendResponse('success', 'تم تحديد الإشعار كمقروء');
    sendResponse('error', 'الإشعار غير موجود أو ليس لك', null, 404);
} catch (Exception $e) {
    api_log('mark_single_notification_read error: ' . $e->getMessage());
    sendResponse('error', 'فشل التحديث: ' . $e->getMessage(), null, 500);
}
