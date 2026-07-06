-- ============================================================
-- ديوني - Supabase Database Schema v2
-- نفّذ هذا الملف في Supabase SQL Editor
-- ============================================================

-- ============================================================
-- 1. جدول المستخدمين الإضافي
-- ============================================================
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  user_type   TEXT NOT NULL CHECK (user_type IN ('merchant','customer','admin')),
  full_name   TEXT NOT NULL,
  phone       TEXT UNIQUE NOT NULL,
  is_active   BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 2. جدول التجار
-- ============================================================
CREATE TABLE IF NOT EXISTS public.merchants (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  merchant_name   TEXT NOT NULL,
  business_name   TEXT,
  phone           TEXT UNIQUE NOT NULL,
  sub_status      TEXT DEFAULT 'trial',
  end_at          TIMESTAMPTZ,
  is_active       BOOLEAN DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 3. جدول العملاء
-- ============================================================
CREATE TABLE IF NOT EXISTS public.customers (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  customer_name   TEXT NOT NULL,
  phone           TEXT,
  address         TEXT,
  is_active       BOOLEAN DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 4. جدول العلاقات (طلبات الربط بين التاجر والعميل)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.requests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id     UUID NOT NULL REFERENCES public.merchants(id) ON DELETE CASCADE,
  customer_id     UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
  status          INTEGER DEFAULT 0,       -- 0=معلق, 1=مقبول, 2=موقف
  account_limit   NUMERIC(12,2) DEFAULT 0, -- سقف الدين المسموح
  total_debt      NUMERIC(12,2) DEFAULT 0, -- إجمالي الدين الحالي
  today_debt      NUMERIC(12,2) DEFAULT 0, -- دين اليوم (مُحسَّب بـ trigger)
  is_active       BOOLEAN DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(merchant_id, customer_id)
);

-- ============================================================
-- 5. جدول العمليات (ديون + مدفوعات)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.transactions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id    UUID NOT NULL REFERENCES public.requests(id) ON DELETE CASCADE,
  merchant_id   UUID NOT NULL REFERENCES public.merchants(id) ON DELETE CASCADE,
  type          TEXT NOT NULL CHECK (type IN ('debt','payment')),
  amount        NUMERIC(12,2) NOT NULL,
  note          TEXT,
  date          TIMESTAMPTZ DEFAULT NOW(),
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 6. جدول أصناف العمليات التفصيلية
-- ============================================================
CREATE TABLE IF NOT EXISTS public.transaction_items (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id  UUID NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE,
  item_name       TEXT,
  quantity        NUMERIC(10,3) DEFAULT 1,
  price           NUMERIC(12,2) DEFAULT 0,
  total           NUMERIC(12,2) DEFAULT 0
);

-- ============================================================
-- 7. جدول المحافظ / وسائل الدفع للتاجر
-- ============================================================
CREATE TABLE IF NOT EXISTS public.wallets (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id    UUID NOT NULL REFERENCES public.merchants(id) ON DELETE CASCADE,
  wallet_type    TEXT,
  wallet_number  TEXT,
  notes          TEXT,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 8. جدول الإشعارات
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  message     TEXT NOT NULL,
  is_read     BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 9. جدول الإعلانات
-- ============================================================
CREATE TABLE IF NOT EXISTS public.ads (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  image_url   TEXT,
  title       TEXT,
  link        TEXT,
  clicks      INTEGER DEFAULT 0,
  is_active   BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TRIGGER: تحديث total_debt تلقائياً بعد كل عملية
-- ============================================================
CREATE OR REPLACE FUNCTION update_request_total_debt()
RETURNS TRIGGER AS $$
DECLARE
  rid UUID;
BEGIN
  rid := COALESCE(NEW.request_id, OLD.request_id);

  UPDATE public.requests
  SET
    total_debt = (
      SELECT COALESCE(
        SUM(CASE WHEN type='debt' THEN amount ELSE -amount END), 0)
      FROM public.transactions
      WHERE request_id = rid
    ),
    today_debt = (
      SELECT COALESCE(
        SUM(CASE WHEN type='debt' THEN amount ELSE 0 END), 0)
      FROM public.transactions
      WHERE request_id = rid
        AND date::date = NOW()::date
    )
  WHERE id = rid;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_update_debt ON public.transactions;
CREATE TRIGGER trg_update_debt
AFTER INSERT OR UPDATE OR DELETE ON public.transactions
FOR EACH ROW EXECUTE FUNCTION update_request_total_debt();

-- ============================================================
-- FUNCTION: لوحة تحكم التاجر
-- ============================================================
CREATE OR REPLACE FUNCTION get_merchant_dashboard(p_merchant_id UUID)
RETURNS JSON AS $$
DECLARE result JSON;
BEGIN
  SELECT json_build_object(
    'total_customers', (
      SELECT COUNT(*) FROM requests
      WHERE merchant_id = p_merchant_id AND status = 1
    ),
    'total_debts', (
      SELECT COALESCE(SUM(total_debt), 0)
      FROM requests
      WHERE merchant_id = p_merchant_id AND status = 1
    ),
    'today_debts', (
      SELECT COALESCE(SUM(amount), 0)
      FROM transactions
      WHERE merchant_id = p_merchant_id
        AND type = 'debt'
        AND date::date = NOW()::date
    )
  ) INTO result;
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: لوحة تحكم المدير
-- ============================================================
CREATE OR REPLACE FUNCTION get_admin_dashboard()
RETURNS JSON AS $$
DECLARE result JSON;
BEGIN
  SELECT json_build_object(
    'merchants_count', (SELECT COUNT(*) FROM merchants WHERE is_active = true),
    'customers_count', (SELECT COUNT(*) FROM customers WHERE is_active = true),
    'total_debt',      (SELECT COALESCE(SUM(total_debt), 0) FROM requests WHERE status = 1),
    'pending_req',     (SELECT COUNT(*) FROM requests WHERE status = 0),
    'active_ads',      (SELECT COUNT(*) FROM ads WHERE is_active = true)
  ) INTO result;
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCTION: نقر الإعلان
-- ============================================================
CREATE OR REPLACE FUNCTION increment_ad_clicks(ad_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE ads SET clicks = clicks + 1 WHERE id = ad_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE public.user_profiles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.merchants         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.requests          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ads               ENABLE ROW LEVEL SECURITY;

-- user_profiles
CREATE POLICY "profile_select_own" ON public.user_profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "profile_insert_own" ON public.user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "profile_update_own" ON public.user_profiles
  FOR UPDATE USING (auth.uid() = id);

-- merchants
CREATE POLICY "merchant_all_own" ON public.merchants
  FOR ALL USING (auth.uid() = user_id);
-- تاجر: اقرأ بيانات التاجر للعملاء المرتبطين
CREATE POLICY "merchant_read_linked" ON public.merchants
  FOR SELECT USING (true);

-- customers
CREATE POLICY "customer_all_own" ON public.customers
  FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "customer_read_by_merchant" ON public.customers
  FOR SELECT USING (true);

-- requests
CREATE POLICY "request_all" ON public.requests
  FOR ALL USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
    OR
    customer_id IN (SELECT id FROM customers WHERE user_id = auth.uid())
  );

-- transactions
CREATE POLICY "transaction_all" ON public.transactions
  FOR ALL USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
    OR
    request_id IN (
      SELECT r.id FROM requests r
      JOIN customers c ON c.id = r.customer_id
      WHERE c.user_id = auth.uid()
    )
  );

-- transaction_items
CREATE POLICY "items_all" ON public.transaction_items
  FOR ALL USING (
    transaction_id IN (
      SELECT t.id FROM transactions t
      WHERE t.merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
    )
  );

-- wallets
CREATE POLICY "wallet_merchant_own" ON public.wallets
  FOR ALL USING (
    merchant_id IN (SELECT id FROM merchants WHERE user_id = auth.uid())
  );
CREATE POLICY "wallet_read_by_customer" ON public.wallets
  FOR SELECT USING (true);

-- notifications
CREATE POLICY "notification_own" ON public.notifications
  FOR ALL USING (user_id = auth.uid());

-- ads
CREATE POLICY "ads_read_all" ON public.ads
  FOR SELECT USING (true);
CREATE POLICY "ads_admin_write" ON public.ads
  FOR ALL USING (
    auth.uid() IN (
      SELECT id FROM user_profiles WHERE user_type = 'admin'
    )
  );

-- ============================================================
-- إنشاء حساب مدير (بعد تشغيل الملف)
-- أنشئ المستخدم في Supabase Auth، ثم نفّذ:
-- INSERT INTO user_profiles (id, user_type, full_name, phone)
-- VALUES ('<USER_UUID>', 'admin', 'المدير', '000000000');
-- ============================================================
