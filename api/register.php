<?php
/**
 * api/register.php
 * تسجيل مستخدم جديد (merchant أو customer)
 * يستخدم getRequestData() و PDO من config/db.php
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../utils/send_otp.php';

$data = getRequestData();

if (!isset($data['User-Name'], $data['User-phone'], $data['Password'], $data['User-type'])) {
    sendResponse('error', 'بيانات التسجيل غير مكتملة', null, 400);
}

$userName = trim($data['User-Name']);
$userPhone = trim($data['User-phone']);
$passwordRaw = $data['Password'];
$userType = $data['User-type']; // merchant | customer

try {
    $pdo = getPDO();
    $pdo->beginTransaction();

    // تحقق من تكرار رقم الهاتف
    $stmt = $pdo->prepare("SELECT `User-id` FROM users WHERE `User-phone` = ? LIMIT 1");
    $stmt->execute([$userPhone]);
    if ($stmt->fetch()) {
        $pdo->rollBack();
        sendResponse('error', 'رقم الهاتف مسجل مسبقاً', null, 409);
    }

    $hashed = password_hash($passwordRaw, PASSWORD_BCRYPT);
    $userEmail = $data['User-Email'] ?? ($userType . $userPhone . '@local');

    $stmtIns = $pdo->prepare("INSERT INTO users (`User-Name`, `User-phone`, `User-Email`, `Password`, `User-type`, `is_verified`, `is_active`, `created_at`, `updated_at`) VALUES (?, ?, ?, ?, ?, 0, 1, NOW(), NOW())");
    $stmtIns->execute([$userName, $userPhone, $userEmail, $hashed, $userType]);
    $userId = $pdo->lastInsertId();

    if ($userType === 'merchant') {
        $businessName = $data['Business-Name'] ?? $userName;
        $address = $data['Address'] ?? '';
        $stmtM = $pdo->prepare("INSERT INTO merchants (`User-id`, `Merchant-Name`, `Merchant-BusinessName`, `Merchant-address`, `created_at`) VALUES (?, ?, ?, ?, NOW())");
        $stmtM->execute([$userId, $userName, $businessName, $address]);
        // إضافة اشتراك تجريبي
        $start = date('Y-m-d H:i:s');
        $end = date('Y-m-d H:i:s', strtotime('+30 days'));
        $stmtS = $pdo->prepare("INSERT INTO subscriptions (`User-id`,`period`,`status`,`start_at`,`end_at`,`created_at`) VALUES (?, 'monthly', 'trial', ?, ?, NOW())");
        $stmtS->execute([$userId, $start, $end]);
    } else {
        $customerAddress = $data['Customer-address'] ?? '';
        $stmtC = $pdo->prepare("INSERT INTO customers (`User-id`, `Customer-Name`, `Customer-address`, `created_at`) VALUES (?, ?, ?, NOW())");
        $stmtC->execute([$userId, $userName, $customerAddress]);
    }

    // انشاء OTP وإرساله (يمكن تعديل sendOTP لتتكامل مع واتساب أو SMS)
    $otp = rand(100000, 999999);
    $stmtOtp = $pdo->prepare("UPDATE users SET verification_code = ? WHERE `User-id` = ?");
    $stmtOtp->execute([$otp, $userId]);

    // محاولة الإرسال (قد يُرجع مصفوفة حالة)
    $sendRes = sendOTPviaWhatsApp($userPhone, $otp);

    $pdo->commit();

    sendResponse('success', 'تم إنشاء الحساب بنجاح', ['user_id' => (int)$userId, 'otp_debug' => $otp]);

} catch (Exception $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    api_log('register error: ' . $e->getMessage());
    sendResponse('error', 'فشل التسجيل', null, 500);
}
