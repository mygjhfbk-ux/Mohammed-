# مشروع باك‑إند (Refactor)

هذا الفرع يحتوي على نسخة مُرتبة ومحسّنة من باك‑إند المشروع، مع ملفات إعدادات، توثيق JWT بسيط، ونسخة محسّنة من endpoint لرفع الإعلانات.

محتويات مهمة:
- config/db.php         => إعداد PDO، CORS، دوال مساعدة
- auth/jwt_helper.php   => دوال توليد وفك JWT بدون Composer
- auth/middleware.php   => دالة authenticate() تستخدم Authorization Bearer token
- api/add_ad.php        => endpoint مُحسّن لرفع الإعلانات (محمية بالتوكن)
- migrations/mc_db_new.sql => ملف SQL لإنشاء القاعدة (تحسينات)
- .env.example          => مثال متغيرات البيئة
- .gitignore            => تجاهل مجلدات مثل uploads وlogs

كيفية التشغيل محلياً (بسيط):
1. انسخ المشروع إلى مجلد الخادم (مثلاً /var/www/html/project)
2. أنشئ ملف .env في جذر المشروع مع القيم التالية:

```
DB_HOST=127.0.0.1
DB_NAME=mc_db
DB_USER=root
DB_PASS=
DB_CHARSET=utf8mb4
APP_ENV=development
ALLOWED_ORIGINS=*
JWT_SECRET=YOUR_LONG_SECRET_HERE
```

3. تأكد من إنشاء مجلدات uploads/ وlogs/ وأعطها صلاحية كتابة من قبل المستخدم الذي يشغّل الويب سيرفر.
4. استورد migrations/mc_db_new.sql في MySQL لإنشاء الجداول (أو استعن بقاعدة البيانات الحالية بعد أخذ نسخة احتياطية).
5. اختبر endpoint رفع الإعلان باستخدام Postman (نوع طلب multipart/form-data):
   - URL: http://your-host/api/add_ad.php
   - Authorization: Bearer <ACCESS_TOKEN>
   - الحقول: title, link, type, image (ملف)

ملاحظات أمنية:
- لا تضع JWT_SECRET في المستودع; ضعها في .env على الخادم.
- غيّر ALLOWED_ORIGINS لتحديد الدومينات المسموح بها في الإنتاج.

