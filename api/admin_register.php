<?php
/**
 * api/admin_register.php
 * تسجيل حساب مدير (محمي بمفتاح إداري في الطلب) — نوص�� باستبدال هذا بمراجعة الصلاحيات لاحقاً
 */

require_once __DIR__ . '/../config/db.php';

$data = $_POST;
$name = $data['name'] ?? '';
$phone = $data['phone'] ?? '';
$password = $data['password'] ?? '';
$adminKey = $data['admin_key'] ?? '';

// مفتاح إداري مؤقت — الأفضل استبداله بتسجيل خاص بالأدوار
$ADMIN_SECRET_KEY = getenv('ADMIN_SECRET_KEY') ?: 'ALQADI';

try {
    if ($adminKey !== $ADMIN_SECRET_KEY) {
        sendResponse('error', 'رمز أمان الإدارة غير صحيح', null, 403);
    }
    $pdo = getPDO();
    $stmt = $pdo->prepare("SELECT * FROM users WHERE `User-phone` = ? LIMIT 1");
    $stmt->execute([$phone]);
    if ($stmt->fetch()) sendResponse('error', 'هذا الرقم مسجل مسبقاً', null, 409);

    $hashed = password_hash($password, PASSWORD_BCRYPT);
    $ins = $pdo->prepare("INSERT INTO users (`User-Name`,`User-phone`,`Password`,`User-type`,`is_verified`,`is_active`,`created_at`) VALUES (?, ?, ?, 'admin', 1, 1, NOW())");
    $ins->execute([$name, $phone, $hashed]);
    sendResponse('success', 'تم إنشاء حساب المدير بنجاح');
} catch (Exception $e) {
    api_log('admin_register error: ' . $e->getMessage());
    sendResponse('error', 'فشل التسجيل: ' . $e->getMessage(), null, 500);
}
