<?php
/**
 * api/add_ad.php
 * نسخة محسّنة لرفع إعلان مع التحقق من التوكن وحماية رفع الملفات
 */

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../auth/middleware.php';

// هذا endpoint يقبل طلب POST مع الحقول: title, link, type, image (multipart/form-data)
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse('error', 'Method not allowed', null, 405);
}

// المصادقة: يجب أن يكون المستخدم مسجلاً (قد نتحقق لاحقاً من أن له صلاحية admin)
$user = authenticate();

// تحقق من وجود الملف ونوعه
if (!isset($_FILES['image'])) {
    sendResponse('error', 'No image uploaded', null, 400);
}

$title = trim($_POST['title'] ?? '');
$link = trim($_POST['link'] ?? '');
$type = trim($_POST['type'] ?? 'slider');

if ($title === '') sendResponse('error', 'Title is required', null, 422);

$image = $_FILES['image'];

// إعدادات رفع من config
$uploadBase = __DIR__ . '/../uploads/ads/';
if (!is_dir($uploadBase)) @mkdir($uploadBase, 0755, true);

$maxSize = 5 * 1024 * 1024; // 5MB
$allowedMimes = ['image/jpeg','image/png','image/webp'];

if ($image['error'] !== UPLOAD_ERR_OK) {
    sendResponse('error', 'File upload error code: ' . $image['error'], null, 400);
}

if ($image['size'] > $maxSize) {
    sendResponse('error', 'File too large', null, 400);
}

$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mime = finfo_file($finfo, $image['tmp_name']);
finfo_close($finfo);

if (!in_array($mime, $allowedMimes, true)) {
    sendResponse('error', 'Invalid file type', null, 400);
}

// توليد اسم آمن للملف
$ext = pathinfo($image['name'], PATHINFO_EXTENSION);
$ext = strtolower($ext);
$basename = bin2hex(random_bytes(12));
$imageName = time() . '_' . $basename . '.' . $ext;
$target = $uploadBase . $imageName;

if (!move_uploaded_file($image['tmp_name'], $target)) {
    sendResponse('error', 'Failed to move uploaded file', null, 500);
}

// إدخال سجل في قاعدة البيانات
try {
    $pdo = getPDO();
    $sql = "INSERT INTO ads (ad_title, ad_image, ad_link, ad_type, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, 1, NOW(), NOW())";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$title, $imageName, $link, $type]);
    sendResponse('success', 'تم إضافة الإعلان', ['ad_id' => $pdo->lastInsertId()]);
} catch (Exception $e) {
    // حاول حذف الملف إذا فشل الإدخال
    @unlink($target);
    api_log('add_ad error: ' . $e->getMessage());
    sendResponse('error', 'Database error', null, 500);
}
