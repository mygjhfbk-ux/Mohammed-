<?php
/**
 * api/payment_reports.php
 * تقارير الدفعات لمدى زمني
 * params: from, to, merchant_id (admin only)
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

$user = authenticate();
$from = $_GET['from'] ?? date('Y-m-01');
$to = $_GET['to'] ?? date('Y-m-t');

try {
    $pdo = getPDO();
    $params = [$from, $to];
    if ($user['User-type'] === 'merchant') {
        $stmtM = $pdo->prepare("SELECT `Merchant-id` FROM merchants WHERE `User-id` = ? LIMIT 1");
        $stmtM->execute([$user['User-id']]);
        $m = $stmtM->fetch(PDO::FETCH_ASSOC);
        $merchantId = $m['Merchant-id'];
        $query = "SELECT DATE(t.`Transaction-Date`) as dt, SUM(CASE WHEN t.`Transaction-type`='payment' THEN t.Amount ELSE 0 END) as payments, SUM(CASE WHEN t.`Transaction-type`='debt' THEN t.Amount ELSE 0 END) as debts FROM transactions t WHERE t.`Merchant-id` = ? AND DATE(t.`Transaction-Date`) BETWEEN ? AND ? GROUP BY DATE(t.`Transaction-Date`) ORDER BY dt ASC";
        array_unshift($params, $merchantId);
    } elseif ($user['User-type'] === 'admin' && isset($_GET['merchant_id'])) {
        $merchantId = (int)$_GET['merchant_id'];
        $query = "SELECT DATE(t.`Transaction-Date`) as dt, SUM(CASE WHEN t.`Transaction-type`='payment' THEN t.Amount ELSE 0 END) as payments, SUM(CASE WHEN t.`Transaction-type`='debt' THEN t.Amount ELSE 0 END) as debts FROM transactions t WHERE t.`Merchant-id` = ? AND DATE(t.`Transaction-Date`) BETWEEN ? AND ? GROUP BY DATE(t.`Transaction-Date`) ORDER BY dt ASC";
        array_unshift($params, $merchantId);
    } else {
        $query = "SELECT DATE(t.`Transaction-Date`) as dt, SUM(CASE WHEN t.`Transaction-type`='payment' THEN t.Amount ELSE 0 END) as payments, SUM(CASE WHEN t.`Transaction-type`='debt' THEN t.Amount ELSE 0 END) as debts FROM transactions t WHERE DATE(t.`Transaction-Date`) BETWEEN ? AND ? GROUP BY DATE(t.`Transaction-Date`) ORDER BY dt ASC";
    }

    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    sendResponse('success','Reports fetched',$rows);
} catch (Exception $e) {
    api_log('payment_reports error: '.$e->getMessage());
    sendResponse('error','Server error',null,500);
}
