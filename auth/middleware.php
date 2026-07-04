<?php
/**
 * auth/middleware.php
 * دالة authenticate() لفك توكن Authorization: Bearer <token>
 * تعيد associative array للمستخدم أو تُرجع JSON 401 وتخرج
 */

require_once __DIR__ . '/../auth/jwt_helper.php';
require_once __DIR__ . '/../config/db.php';

function getAuthorizationHeader(): ?string {
    $headers = null;
    if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $headers = trim($_SERVER['HTTP_AUTHORIZATION']);
    } elseif (function_exists('apache_request_headers')) {
        $requestHeaders = apache_request_headers();
        if (isset($requestHeaders['Authorization'])) {
            $headers = trim($requestHeaders['Authorization']);
        }
    }
    return $headers;
}

function authenticate(): array {
    $authHeader = getAuthorizationHeader();
    if (!$authHeader) {
        sendResponse('error', 'Authorization header missing', null, 401);
    }

    if (!preg_match('/Bearer\s+(\S+)/', $authHeader, $matches)) {
        sendResponse('error', 'Invalid Authorization header', null, 401);
    }

    $token = $matches[1];
    $secret = getenv('JWT_SECRET') ?: 'REDACTED_CHANGE_THIS';
    $payload = jwt_decode($token, $secret);
    if (!$payload) {
        sendResponse('error', 'Invalid or expired token', null, 401);
    }

    // يتوقع أن يحتوي البيلود على sub => user id
    if (!isset($payload['sub'])) {
        sendResponse('error', 'Invalid token payload', null, 401);
    }

    $pdo = getPDO();
    $stmt = $pdo->prepare("SELECT * FROM users WHERE `User-id` = ? LIMIT 1");
    $stmt->execute([(int)$payload['sub']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$user) {
        sendResponse('error', 'User not found', null, 401);
    }

    // أزل الحقل الحساس قبل الإرجاع
    unset($user['Password']);
    return $user;
}
