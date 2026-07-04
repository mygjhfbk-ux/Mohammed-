<?php
/**
 * api/refresh.php
 * تجديد Access Token باستخدام Refresh Token
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/jwt_helper.php';

$data = getRequestData();
$refresh = $data['refresh_token'] ?? null;
if (!$refresh) sendResponse('error', 'refresh_token required', null, 400);

try {
    $pdo = getPDO();
    $stmt = $pdo->prepare("SELECT * FROM refresh_tokens WHERE token = ? LIMIT 1");
    $stmt->execute([$refresh]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) sendResponse('error', 'Invalid refresh token', null, 401);
    if (strtotime($row['expires_at']) < time()) {
        // حذف التوكن من الجدول
        $del = $pdo->prepare("DELETE FROM refresh_tokens WHERE id = ?");
        $del->execute([$row['id']]);
        sendResponse('error', 'Refresh token expired', null, 401);
    }

    $userId = (int)$row['user_id'];
    $secret = getenv('JWT_SECRET') ?: 'REDACTED_CHANGE_THIS';
    $accessToken = jwt_encode(['sub' => $userId], $secret, 3600);

    sendResponse('success', 'Token refreshed', ['access_token' => $accessToken, 'expires_in' => 3600]);

} catch (Exception $e) {
    api_log('refresh error: ' . $e->getMessage());
    sendResponse('error', 'Server error', null, 500);
}
