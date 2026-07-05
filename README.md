# Supabase + Flutter project (phone + password auth)

This branch implements a Flutter scaffold integrated with Supabase using "phone + password" auth by converting the phone number into a generated email (e.g. `+966512345678@diuni.local`). This removes the OTP flow and lets Supabase Auth manage sessions/passwords.

What is included:
- migrations/init.sql : SQL to create the `profiles` table and indexes
- Flutter app skeleton in `lib/` with Supabase initialization
- AuthController using Supabase for sign up / sign in

Important
- Do NOT commit real keys. Fill a local `.env` from `.env.example`.
- You must create a Supabase project and enable Auth (email/password). Use the generated email scheme for users.

Quick start
1. Create a Supabase project at https://app.supabase.com
2. In your project settings copy `SUPABASE_URL` and `ANON KEY` into a local `.env` file
3. Run the migration SQL (`migrations/init.sql`) in Supabase SQL editor (or via psql)
4. From the project root run:

```bash
flutter pub get
flutter run
```

Notes on phone usage
- The app treats the phone number as the username by mapping it to a pseudo-email: `<phone>@diuni.local`.
- No OTP or WhatsApp messages are sent in this branch.
