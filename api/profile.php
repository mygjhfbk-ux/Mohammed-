<?php
/**
 * api/profile.php
 * يعيد بيانات المستخدم المحمي
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

$user = authenticate();
// بإمكانك اجلب بيانات إضافية بناء على نوع المستخدم
$pdo = getPDO();
$profile = null;
if ($user['User-type'] === 'merchant') {
    $stmt = $pdo->prepare("SELECT * FROM merchants WHERE `User-id` = ? LIMIT 1");
    $stmt->execute([$user['User-id']]);
    $profile = $stmt->fetch(PDO::FETCH_ASSOC);
} elseif ($user['User-type'] === 'customer') {
    $stmt = $pdo->prepare("SELECT * FROM customers WHERE `User-id` = ? LIMIT 1");
    $stmt->execute([$user['User-id']]);
    $profile = $stmt->fetch(PDO::FETCH_ASSOC);
}

sendResponse('success', 'Profile fetched', ['user' => $user, 'profile' => $profile]);
