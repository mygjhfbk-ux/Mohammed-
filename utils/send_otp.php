<?php
/**
 * utils/send_otp.php
 * دالة إرسال OTP (حاليًا تستخدم طلب HTTP إلى خدمة محلية أو تسجل الكود في اللوق)
 */

function sendOTPviaWhatsApp($phone, $otp) {
    // إذا لديك خدمة محلية على http://localhost:3000/send-otp يمكنك إلغاء التعليق التالي
    try {
        $apiUrl = getenv('OTP_API') ?: null; // مثال: http://localhost:3000/send-otp
        if ($apiUrl) {
            $data = [
                "phone" => "967$phone",
                "message" => "كود التحقق: $otp"
            ];
            $ch = curl_init($apiUrl);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
            curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
            $resp = curl_exec($ch);
            $err = curl_error($ch);
            curl_close($ch);
            if ($err) return ['success' => false, 'error' => $err];
            return json_decode($resp, true);
        }
    } catch (Exception $e) {
        // استمر
    }
    // إفتراضياً، سجّل الكود في لوق للتطوير
    $log = __DIR__ . '/../logs/otp.log';
    @file_put_contents($log, date('Y-m-d H:i:s') . " | OTP for $phone : $otp" . PHP_EOL, FILE_APPEND);
    return ['success' => true, 'debug' => $otp];
}
