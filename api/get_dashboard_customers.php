<?php
/**
 * api/get_dashboard_customers.php
 * ملخص داشبورد للعميل بناء على User-id
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

$user = authenticate();
// يمكن السماح للعميل فقط أو للمدير/التاجر برؤية هذه المعلومات

try {
    $pdo = getPDO();
    $userId = $user['User-id'];

    $stmtC = $pdo->prepare("SELECT `Customer-id`, `Customer-Name` FROM customers WHERE `User-id` = ? LIMIT 1");
    $stmtC->execute([$userId]);
    $customer = $stmtC->fetch(PDO::FETCH_ASSOC);
    if (!$customer) sendResponse('error', 'حساب العميل غير مكتمل أو غير موجود', null, 404);

    $customerId = $customer['Customer-id'];
    $stmtTotal = $pdo->prepare("SELECT SUM(total_debt) as total FROM requests WHERE `Customer-id` = ? AND `is_active` = 1");
    $stmtTotal->execute([$customerId]);
    $totalDebt = $stmtTotal->fetchColumn() ?: 0;

    $stmtToday = $pdo->prepare("SELECT SUM(t.Amount) as today FROM transactions t INNER JOIN requests r ON t.`Request-id` = r.`Request-id` WHERE r.`Customer-id` = ? AND DATE(t.`Transaction-Date`) = CURDATE() AND t.`Transaction-type` = 'debt'");
    $stmtToday->execute([$customerId]);
    $todayDebt = $stmtToday->fetchColumn() ?: 0;

    $stmtMerchants = $pdo->prepare("SELECT m.`Merchant-BusinessName` as name, r.`total_debt` FROM requests r JOIN merchants m ON r.`Merchant-id` = m.`Merchant-id` WHERE r.`Customer-id` = ? AND r.`Request-status` = 1");
    $stmtMerchants->execute([$customerId]);
    $merchantList = $stmtMerchants->fetchAll(PDO::FETCH_ASSOC);

    $stmtRecent = $pdo->prepare("SELECT t.Amount, t.`Transaction-type` as type, t.`Transaction-Date` as date, t.Description, m.`Merchant-BusinessName` as merchant_name FROM transactions t INNER JOIN requests r ON t.`Request-id` = r.`Request-id` INNER JOIN merchants m ON t.`Merchant-id` = m.`Merchant-id` WHERE r.`Customer-id` = ? ORDER BY t.`Transaction-Date` DESC LIMIT 5");
    $stmtRecent->execute([$customerId]);
    $recent = $stmtRecent->fetchAll(PDO::FETCH_ASSOC);

    sendResponse('success', 'Dashboard fetched', ['summary'=>['name'=>$customer['Customer-Name'],'customerId'=>$customerId,'total_debt'=> (float)$totalDebt,'today_debt'=> (float)$todayDebt],'merchants'=>$merchantList,'recent_transactions'=>$recent]);
} catch (Exception $e) {
    api_log('get_dashboard_customers error: ' . $e->getMessage());
    sendResponse('error', 'خطأ في السيرفر: ' . $e->getMessage(), null, 500);
}
