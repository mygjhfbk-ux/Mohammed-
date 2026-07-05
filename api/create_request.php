<?php
/**
 * api/create_request.php
 * إنشاء علاقة (Request) بين تاجر وعميل
 * body: customer_name, customer_id (optional if linked), account_limit (optional), address (optional)
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') sendResponse('error','Method not allowed',null,405);

$user = authenticate();
if ($user['User-type'] !== 'merchant') sendResponse('error','ممنوع',null,403);

$data = getRequestData();
$customerName = trim($data['customer_name'] ?? '');
$customerId = $data['customer_id'] ?? null; // existing Customer-id
$accountLimit = isset($data['account_limit']) ? (float)$data['account_limit'] : 0.00;
$address = $data['address'] ?? '';

if ($customerName === '') sendResponse('error','اسم العميل مطلوب',null,400);

try {
    $pdo = getPDO();
    $stmtM = $pdo->prepare("SELECT `Merchant-id` FROM merchants WHERE `User-id` = ? LIMIT 1");
    $stmtM->execute([$user['User-id']]);
    $m = $stmtM->fetch(PDO::FETCH_ASSOC);
    if (!$m) sendResponse('error','بيانات التاجر غير كاملة',null,403);
    $merchantId = $m['Merchant-id'];

    $pdo->beginTransaction();

    if ($customerId) {
        // تأكد أن العميل موجود
        $stmtC = $pdo->prepare("SELECT `Customer-id` FROM customers WHERE `Customer-id` = ? LIMIT 1");
        $stmtC->execute([$customerId]);
        if (!$stmtC->fetch()) {
            $pdo->rollBack();
            sendResponse('error','العميل غير موجود',null,404);
        }
    }

    $stmtIns = $pdo->prepare("INSERT INTO requests (`Merchant-id`,`Customer-id`,`Request-status`,`total_debt`,`account_limit`,`is_active`,`Customer-Name`,`is_local`,`address`,`created_at`) VALUES (?, ?, 1, 0.00, ?, 1, ?, ?, ?, NOW())");
    $isLocal = $customerId ? 0 : 1;
    $custIdValue = $customerId ? $customerId : 0;
    $stmtIns->execute([$merchantId, $custIdValue, $accountLimit, $customerName, $isLocal, $address]);
    $requestId = $pdo->lastInsertId();

    $pdo->commit();
    sendResponse('success','تم إنشاء الطلب', ['Request-id' => $requestId]);
} catch (Exception $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    api_log('create_request error: '.$e->getMessage());
    sendResponse('error','فشل إنشاء الطلب',null,500);
}
