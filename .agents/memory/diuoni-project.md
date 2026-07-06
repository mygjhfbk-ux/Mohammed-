---
name: ديوني Flutter project
description: Key decisions and constraints for the ديوني debt-management Flutter app (Supabase backend, GetX, package com.diuoni.app_merchant_customer)
---

## Auth approach
- Phone stored as `phone@diuoni.app` email in Supabase Auth (no SMS OTP)
- `SupabaseService.phoneToEmail(phone)` handles the conversion

## Schema naming (critical — do not use old names)
- `requests.account_limit` — NOT `debt_limit`
- `requests.is_active`, `requests.today_debt` — extra cols updated by trigger
- `wallets.wallet_type`, `wallets.wallet_number` — NOT `type`/`number`
- `transactions.note` — NOT `description`

**Why:** The schema was rebuilt to match what all controllers read/write. Using old names causes Supabase 400 errors.

## Fonts
- `google_fonts: ^6.2.1` added to pubspec; `GoogleFonts.cairoTextTheme()` used in ThemeData
- No local font files required (assets/fonts/ directory not referenced in pubspec)
- PDF generation falls back to Helvetica when Cairo TTF is absent (graceful try/catch)

**Why:** Adding local TTF files to git is fragile; google_fonts resolves at runtime.

## Supabase credentials
- Injected at build time via `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
- In Codemagic: stored as encrypted env vars, passed to `flutter build apk`
- Code uses `const String.fromEnvironment(...)` with placeholder defaults

## All IDs are String (UUID)
- All `.read()` and DB values are `.toString()`'d before use
- `box.read('Profile-id')` holds the merchant/customer UUID (not int)

## Controllers registered permanent in main.dart
All 14 controllers are `Get.put(..., permanent: true)` at startup — no lazy bindings needed for core controllers.
