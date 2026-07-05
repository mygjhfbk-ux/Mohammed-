<?php
/**
 * api/wallets_manager.php
 * إدارة محافظ التاجر: إضافة/حذف/قائمة
 * body: action=add|delete, merchant_id (optional), data...
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

$user = authenticate();
if ($user['User-type'] !== 'merchant' && $user['User-type'] !== 'admin') sendResponse('error','ممنوع',null,403);

$data = getRequestData();
$action = $data['action'] ?? 'list';

try {
    $pdo = getPDO();
    if ($action === 'add') {
        $stmtM = $pdo->prepare("SELECT `Merchant-id` FROM merchants WHERE `User-id` = ? LIMIT 1");
        $stmtM->execute([$user['User-id']]);
        $m = $stmtM->fetch(PDO::FETCH_ASSOC);
        if (!$m) sendResponse('error','بيانات التاجر غير موجودة',null,403);
        $merchantId = $m['Merchant-id'];
        $number = $data['wallet_number'] ?? '';
        $type = $data['wallet_type'] ?? 'default';
        if (!$number) sendResponse('error','wallet_number required',null,400);
        $stmt = $pdo->prepare("INSERT INTO merchant_wallets (merchant_id, wallet_type, wallet_number, notes, created_at) VALUES (?, ?, ?, ?, NOW())");
        $stmt->execute([$merchantId, $type, $number, $data['notes'] ?? '']);
        sendResponse('success','Wallet added', ['wallet_id' => $pdo->lastInsertId()]);
    } elseif ($action === 'delete') {
        $walletId = $data['wallet_id'] ?? null;
        if (!$walletId) sendResponse('error','wallet_id required',null,400);
        $stmt = $pdo->prepare("DELETE FROM merchant_wallets WHERE wallet_id = ?");
        $stmt->execute([$walletId]);
        sendResponse('success','Wallet deleted');
    } else {
        // list
        if ($user['User-type'] === 'merchant') {
            $stmtM = $pdo->prepare("SELECT `Merchant-id` FROM merchants WHERE `User-id` = ? LIMIT 1");
            $stmtM->execute([$user['User-id']]);
            $m = $stmtM->fetch(PDO::FETCH_ASSOC);
            $merchantId = $m['Merchant-id'];
            $stmt = $pdo->prepare("SELECT * FROM merchant_wallets WHERE merchant_id = ?");
            $stmt->execute([$merchantId]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            sendResponse('success','Wallets fetched',$rows);
        } else {
            $stmt = $pdo->query("SELECT * FROM merchant_wallets ORDER BY created_at DESC");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            sendResponse('success','All wallets',$rows);
        }
    }
} catch (Exception $e) {
    api_log('wallets_manager error: '.$e->getMessage());
    sendResponse('error','Server error',null,500);
}
