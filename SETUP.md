# ديوني - دليل إعداد المشروع

## 1. إعداد Supabase

1. أنشئ مشروعاً جديداً على [supabase.com](https://supabase.com)
2. افتح **SQL Editor** وانسخ محتوى `supabase_schema.sql` ونفّذه
3. من **Project Settings → API**، انسخ:
   - `Project URL` → هذا هو `SUPABASE_URL`
   - `anon public key` → هذا هو `SUPABASE_ANON_KEY`
4. أنشئ Storage Bucket باسم `ads` (للإعلانات)، واجعله public

### إنشاء حساب المدير
```sql
-- بعد تشغيل الـ schema، أنشئ مستخدم من Supabase Auth يدوياً
-- ثم نفّذ:
INSERT INTO user_profiles (id, user_type, full_name, phone)
VALUES ('<USER_UUID_FROM_AUTH>', 'admin', 'المدير', '000000000');
```

---

## 2. البناء المحلي (للاختبار)

```bash
flutter pub get

flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

---

## 3. إعداد Codemagic لبناء APK

1. ارفع المشروع على GitHub
2. سجّل في [codemagic.io](https://codemagic.io) وربط المستودع
3. من **Environment variables**، أضف:
   - `SUPABASE_URL` → رابط مشروعك
   - `SUPABASE_ANON_KEY` → مفتاح الـ anon
4. أنشئ Keystore للتوقيع وسمّه `diuoni_keystore` في إعدادات Codemagic
5. شغّل الـ workflow `android-release`

---

## 4. هيكل المشروع

```
lib/
├── core/           # supabase_service + app_constants
├── controllers/
│   ├── auth_controller.dart
│   ├── ads_controller.dart
│   ├── admin_controller/
│   ├── merchant_controller/
│   └── customer_controller/
├── models/         # ad_model.dart
├── services/       # pdf_debt_report_service.dart
├── views/
│   ├── admin/
│   ├── customers/
│   ├── merchant/
│   ├── reports/
│   └── (auth views)
└── widgets/
```

---

## 5. ملاحظات مهمة

- **المصادقة**: الهاتف يُحوَّل لـ email بصيغة `phone@diuoni.app` (لا SMS OTP)
- **الخطوط**: يستخدم Cairo عبر google_fonts (لا يحتاج ملفات محلية)
- **الـ PDF**: عند عدم وجود خط Cairo محلي، يستخدم Helvetica تلقائياً
- **package name**: `com.diuoni.app_merchant_customer`
- **minSdk**: 21
