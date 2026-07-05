<?php
/**
 * api/get_requests.php
 * جلب الطلبات الخاصة بالتاجر أو العميل حسب نوع المستخدم
 * query params: status (optional), merchant_id (admin only), customer_id (admin only)
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

$user = authenticate();
try {
    $pdo = getPDO();
    $params = [];
    if ($user['User-type'] === 'merchant') {
        $stmtM = $pdo->prepare("SELECT `Merchant-id` FROM merchants WHERE `User-id` = ? LIMIT 1");
        $stmtM->execute([$user['User-id']]);
        $m = $stmtM->fetch(PDO::FETCH_ASSOC);
        if (!$m) sendResponse('error','بيانات التاجر غير موجودة',null,403);
        $merchantId = $m['Merchant-id'];
        $query = "SELECT r.*, c.`Customer-Name` as customer_name, c.`Customer-address` as customer_address FROM requests r LEFT JOIN customers c ON r.`Customer-id` = c.`Customer-id` WHERE r.`Merchant-id` = ?";
        $params[] = $merchantId;
    } elseif ($user['User-type'] === 'customer') {
        $stmtC = $pdo->prepare("SELECT `Customer-id` FROM customers WHERE `User-id` = ? LIMIT 1");
        $stmtC->execute([$user['User-id']]);
        $c = $stmtC->fetch(PDO::FETCH_ASSOC);
        if (!$c) sendResponse('error','حساب العميل غير مرتبط',null,403);
        $customerId = $c['Customer-id'];
        $query = "SELECT r.*, m.`Merchant-BusinessName` as merchant_name FROM requests r LEFT JOIN merchants m ON r.`Merchant-id` = m.`Merchant-id` WHERE r.`Customer-id` = ?";
        $params[] = $customerId;
    } else {
        // admin أو غيره: يمكن تمرير merchant_id / customer_id عبر GET
        $query = "SELECT r.*, m.`Merchant-BusinessName` as merchant_name, c.`Customer-Name` as customer_name FROM requests r LEFT JOIN merchants m ON r.`Merchant-id` = m.`Merchant-id` LEFT JOIN customers c ON r.`Customer-id` = c.`Customer-id`";
    }

    // فلترة حسب الحالة
    if (isset($_GET['status'])) {
        $query .= " AND r.`Request-status` = ?";
        $params[] = (int)$_GET['status'];
    }

    $query .= " ORDER BY r.created_at DESC";
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    sendResponse('success','Requests fetched',$rows);
} catch (Exception $e) {
    api_log('get_requests error: '.$e->getMessage());
    sendResponse('error','Server error',null,500);
}
