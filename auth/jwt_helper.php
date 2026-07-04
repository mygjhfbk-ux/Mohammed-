<?php
/**
 * auth/jwt_helper.php
 * توليد وفكّ JWT بسيط باستخدام HS256 بدون اعتمادية على مكتبات خارجية
 * التعليقات بالعربي توضح كيفية الاستخدام
 */

declare(strict_types=1);

// اقرأ السر من متغير البيئة أو يمكنك وضعه في config
$JWT_SECRET = getenv('JWT_SECRET') ?: 'REDACTED_CHANGE_THIS';
$JWT_ALGO = 'HS256';

function base64url_encode(string $data): string {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

function base64url_decode(string $data): string {
    $remainder = strlen($data) % 4;
    if ($remainder) {
        $data .= str_repeat('=', 4 - $remainder);
    }
    return base64_decode(strtr($data, '-_', '+/'));
}

function jwt_encode(array $payload, string $secret, int $expSeconds = 3600): string {
    $header = ['typ' => 'JWT', 'alg' => 'HS256'];
    $now = time();
    $payload['iat'] = $now;
    if (!isset($payload['exp'])) {
        $payload['exp'] = $now + $expSeconds;
    }

    $base64Header = base64url_encode(json_encode($header));
    $base64Payload = base64url_encode(json_encode($payload));
    $signature = hash_hmac('sha256', $base64Header . '.' . $base64Payload, $secret, true);
    $base64Signature = base64url_encode($signature);

    return $base64Header . '.' . $base64Payload . '.' . $base64Signature;
}

function jwt_decode(string $token, string $secret): ?array {
    $parts = explode('.', $token);
    if (count($parts) !== 3) return null;
    [$b64h, $b64p, $b64s] = $parts;

    $header = json_decode(base64url_decode($b64h), true);
    $payload = json_decode(base64url_decode($b64p), true);
    $sig = base64url_decode($b64s);

    if (!$header || !$payload || $sig === false) return null;

    // تحقق من الخوارزمية
    if (!isset($header['alg']) || $header['alg'] !== 'HS256') return null;

    $expectedSig = hash_hmac('sha256', $b64h . '.' . $b64p, $secret, true);
    if (!hash_equals($expectedSig, $sig)) return null;

    // تحقق من الصلاحية الزمنية
    $now = time();
    if (isset($payload['exp']) && $now > $payload['exp']) return null;

    return $payload;
}

// دوال مساعدة لإنشاء access + refresh tokens
function create_access_token(int $userId, string $secret, int $ttl = 3600, array $extra = []): string {
    $payload = array_merge($extra, ['sub' => $userId]);
    return jwt_encode($payload, $secret, $ttl);
}
