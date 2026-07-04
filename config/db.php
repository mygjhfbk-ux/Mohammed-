<?php
/**
 * config/db.php
 * ملف إعداد الاتصال بقاعدة البيانات ورؤوس CORS ودوال مساعدة موحدة
 */
declare(strict_types=1);

$env = getenv('APP_ENV') ?: 'development';

$dbHost   = getenv('DB_HOST') ?: '127.0.0.1';
$dbName   = getenv('DB_NAME') ?: 'mc_db';
$dbUser   = getenv('DB_USER') ?: 'root';
$dbPass   = getenv('DB_PASS') ?: '';
$dbCharset= getenv('DB_CHARSET') ?: 'utf8mb4';

$allowedOriginsEnv = getenv('ALLOWED_ORIGINS');
if ($allowedOriginsEnv) {
    $ALLOWED_ORIGINS = array_map('trim', explode(',', $allowedOriginsEnv));
} else {
    $ALLOWED_ORIGINS = ($env === 'production') ? ['https://your-production-domain.com'] : ['*'];
}

$LOG_FILE = __DIR__ . '/../logs/api.log';
$UPLOAD_DIR = __DIR__ . '/../uploads';

function sendCorsHeaders(array $allowedOrigins): void {
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    if (in_array('*', $allowedOrigins, true) || ($origin && in_array($origin, $allowedOrigins, true))) {
        header("Access-Control-Allow-Origin: " . (in_array('*', $allowedOrigins, true) ? '*' : $origin));
    }
    header("Access-Control-Allow-Methods: POST, GET, OPTIONS, PUT, DELETE");
    header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
    header("Access-Control-Max-Age: 3600");
    header('Content-Type: application/json; charset=UTF-8');

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit();
    }
}

sendCorsHeaders($ALLOWED_ORIGINS);

$dsn = "mysql:host={$dbHost};dbname={$dbName};charset={$dbCharset}";
$pdoOptions = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
    $pdo = new PDO($dsn, $dbUser, $dbPass, $pdoOptions);
} catch (PDOException $e) {
    if ($env === 'production') {
        @file_put_contents($GLOBALS['LOG_FILE'], date('c') . " DB Connection Error: " . $e->getMessage() . PHP_EOL, FILE_APPEND);
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'فشل الاتصال بقاعدة البيانات'], JSON_UNESCAPED_UNICODE);
    } else {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'DB Connection Error: ' . $e->getMessage()], JSON_UNESCAPED_UNICODE);
    }
    exit;
}

function getPDO(): PDO {
    return $GLOBALS['pdo'];
}

function getRequestData(): array {
    $raw = file_get_contents('php://input');
    if ($raw) {
        $decoded = json_decode($raw, true);
        if (json_last_error() === JSON_ERROR_NONE && is_array($decoded) && count($decoded) > 0) {
            return $decoded;
        }
    }
    if (!empty($_POST)) {
        return $_POST;
    }
    return [];
}

function sendResponse(string $status, string $message = '', $data = null, int $httpCode = 200): void {
    http_response_code($httpCode);
    $payload = ['status' => $status, 'message' => $message];
    if ($data !== null) $payload['data'] = $data;
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit();
}

function api_log(string $message): void {
    $logFile = $GLOBALS['LOG_FILE'] ?? __DIR__ . '/../logs/api.log';
    $entry = date('Y-m-d H:i:s') . " | " . $message . PHP_EOL;
    @file_put_contents($logFile, $entry, FILE_APPEND);
}

if (!is_dir($UPLOAD_DIR)) {
    @mkdir($UPLOAD_DIR, 0755, true);
}
if (!is_writable($UPLOAD_DIR)) {
    api_log("تحذير: مجلد الرفع {$UPLOAD_DIR} غير قابل للكتابة");
}
