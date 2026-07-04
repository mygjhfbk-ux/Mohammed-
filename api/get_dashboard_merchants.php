<?php
/**
 * api/get_dashboard_merchants.php
 * ملخص داشبورد للتاجر بناء على User-id
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

$user = authenticate();
if ($user['User-type'] !== 'merchant') sendResponse('error', 'ممنوع', null, 403);

try {
    $pdo = getPDO();
    $userId = $user['User-id'];

    $stmtM = $pdo->prepare("SELECT * FROM merchants WHERE `User-id` = ? LIMIT 1");
    $stmtM->execute([$userId]);
    $merchant = $stmtM->fetch(PDO::FETCH_ASSOC);
    if (!$merchant) sendResponse('error', 'لم يتم العثور على بيانات التاجر', null, 404);

    $merchantId = $merchant['Merchant-id'];
    $today = date('Y-m-d');

    $stmtCust = $pdo->prepare("SELECT COUNT(*) as total_customers FROM requests WHERE `Merchant-id` = ? AND `Request-status` = 1");
    $stmtCust->execute([$merchantId]);
    $totalCustomers = $stmtCust->fetchColumn() ?: 0;

    $stmtDebt = $pdo->prepare("SELECT SUM(total_debt) as total_debts FROM requests WHERE `Merchant-id` = ?");
    $stmtDebt->execute([$merchantId]);
    $totalDebts = $stmtDebt->fetchColumn() ?: 0;

    $stmtToday = $pdo->prepare("SELECT SUM(Amount) as today_sum FROM transactions WHERE `Merchant-id` = ? AND DATE(`Transaction-Date`) = ? AND `Transaction-type` = 'debt'");
    $stmtToday->execute([$merchantId, $today]);
    $todaySum = $stmtToday->fetchColumn() ?: 0;

    $stmtCash = $pdo->prepare("SELECT SUM(Amount) as today_cash FROM transactions WHERE `Merchant-id` = ? AND DATE(`Transaction-Date`) = ? AND `Transaction-type` = 'payment'");
    $stmtCash->execute([$merchantId, $today]);
    $todayCash = $stmtCash->fetchColumn() ?: 0;

    sendResponse('success', 'Merchant dashboard', ['merchant'=>$merchant,'data'=>['total_customers'=>(int)$totalCustomers,'total_debts'=>(float)$totalDebts,'today_debts'=>(float)$todaySum,'today_payments'=>(float)$todayCash]]);
} catch (Exception $e) {
    api_log('get_dashboard_merchants error: ' . $e->getMessage());
    sendResponse('error', 'خطأ في السيرفر: ' . $e->getMessage(), null, 500);
}
