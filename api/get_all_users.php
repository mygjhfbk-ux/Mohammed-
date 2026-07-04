<?php
/**
 * api/get_all_users.php
 * جلب المستخدمين مع بيانات الاشتراك (ممنوع للغير admin)
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

$user = authenticate();
if ($user['User-type'] !== 'admin') sendResponse('error', 'ممنوع', null, 403);

try {
    $pdo = getPDO();
    $query = "SELECT u.*, s.period, s.status as sub_status, s.start_at, s.end_at FROM users u LEFT JOIN subscriptions s ON u.`User-id` = s.`User-id` ORDER BY u.created_at DESC";
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    sendResponse('success', 'Users fetched', $users);
} catch (Exception $e) {
    api_log('get_all_users error: ' . $e->getMessage());
    sendResponse('error', 'فشل جلب البيانات: ' . $e->getMessage(), null, 500);
}
