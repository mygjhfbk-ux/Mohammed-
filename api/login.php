<?php
/**
 * api/login.php
 * تسجيل الدخول وإصدار JWT + Refresh Token
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/jwt_helper.php';

$data = getRequestData();

if (!isset($data['User-phone'], $data['Password'])) {
    sendResponse('error', 'يرجى إدخال رقم الهاتف وكلمة المرور', null, 400);
}

$phone = $data['User-phone'];
$password = $data['Password'];

try {
    $pdo = getPDO();
    $stmt = $pdo->prepare("SELECT * FROM users WHERE `User-phone` = ? LIMIT 1");
    $stmt->execute([$phone]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user || !password_verify($password, $user['Password'])) {
        sendResponse('error', 'رقم الهاتف أو كلمة المرور غير صحيحة', null, 401);
    }

    if ($user['is_active'] == 0) {
        sendResponse('error', 'حسابك غير مفعل، يرجى التواصل مع الدعم', null, 403);
    }

    if ($user['is_verified'] == 0) {
        sendResponse('not_verified', 'يرجى تفعيل حسابك أولاً', ['user_id' => (int)$user['User-id']], 403);
    }

    // أنشئ توكن الوصول (JWT)
    $secret = getenv('JWT_SECRET') ?: 'REDACTED_CHANGE_THIS';
    $accessToken = jwt_encode(['sub' => (int)$user['User-id'], 'role' => $user['User-type']], $secret, 3600);

    // أنشئ refresh token عشوائي وخزنه في جدول refresh_tokens
    $refreshToken = bin2hex(random_bytes(40));
    $expiresAt = date('Y-m-d H:i:s', time() + (60 * 60 * 24 * 30)); // 30 يوم

    // أنشئ جدول refresh_tokens إن لم يكن موجودًا (هام فقط لأول تشغيل)
    $pdo->exec("CREATE TABLE IF NOT EXISTS refresh_tokens (id BIGINT AUTO_INCREMENT PRIMARY KEY, user_id BIGINT NOT NULL, token VARCHAR(255) NOT NULL, expires_at DATETIME NOT NULL, created_at DATETIME DEFAULT NOW()) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

    $stmtIns = $pdo->prepare("INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES (?, ?, ?)");
    $stmtIns->execute([(int)$user['User-id'], $refreshToken, $expiresAt]);

    // لا ترجع الباسورد للمستدعي
    unset($user['Password']);

    sendResponse('success', 'تم تسجيل الدخول', [
        'access_token' => $accessToken,
        'expires_in' => 3600,
        'refresh_token' => $refreshToken,
        'user' => $user
    ]);

} catch (Exception $e) {
    api_log('login error: ' . $e->getMessage());
    sendResponse('error', 'خطأ في السيرفر', null, 500);
}
