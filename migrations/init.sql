-- migrations/init.sql
-- Complete schema for Diuni (Supabase) — profiles, merchants, customers, wallets, transactions, ads, notifications, join_requests, subscriptions, helpful views/indexes and helper RPC functions

-- Enable pgcrypto for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- profiles table: links to auth.users (one row per auth user)
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  phone text NOT NULL,
  name text,
  user_type text NOT NULL DEFAULT 'customer', -- 'merchant' | 'customer' | 'admin'
  business_name text,
  image_path text,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- Unique index on normalized phone (lowercase, trimmed) to avoid duplicates
CREATE UNIQUE INDEX IF NOT EXISTS profiles_phone_idx ON profiles(LOWER(TRIM(phone)));

-- merchants: additional merchant-specific data (one-to-one with profiles where user_type = 'merchant')
CREATE TABLE IF NOT EXISTS merchants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  merchant_name text,
  is_subscribed boolean DEFAULT false,
  sub_status text,
  sub_expiry timestamptz,
  created_at timestamptz DEFAULT now()
);

-- customers: additional customer-specific data (one-to-one with profiles where user_type = 'customer')
CREATE TABLE IF NOT EXISTS customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  linked_merchant_id uuid REFERENCES merchants(id), -- optional link to a merchant
  accepted boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- wallets: merchant wallets
CREATE TABLE IF NOT EXISTS wallets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id uuid REFERENCES merchants(id) ON DELETE CASCADE,
  name text,
  balance numeric DEFAULT 0,
  currency text DEFAULT 'SAR',
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- transactions: debts and payments
CREATE TABLE IF NOT EXISTS transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id uuid REFERENCES merchants(id),
  customer_id uuid REFERENCES customers(id),
  wallet_id uuid REFERENCES wallets(id),
  amount numeric NOT NULL CHECK (amount >= 0),
  type text NOT NULL CHECK (type IN ('debt','payment')),
  status text DEFAULT 'active', -- 'active', 'deleted', 'reversed'
  notes text,
  created_at timestamptz DEFAULT now()
);

-- Ads table (optional merchant-owned ads)
CREATE TABLE IF NOT EXISTS ads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id uuid REFERENCES merchants(id),
  title text,
  image_path text,
  url text,
  clicks int DEFAULT 0,
  active boolean DEFAULT true,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- notifications for users
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES profiles(id),
  title text,
  body text,
  is_read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- join_requests: merchant invites or customer requests to join a merchant
CREATE TABLE IF NOT EXISTS join_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id uuid REFERENCES merchants(id) ON DELETE CASCADE,
  customer_id uuid REFERENCES customers(id) ON DELETE CASCADE,
  status text DEFAULT 'pending', -- 'pending','accepted','rejected'
  message text,
  created_at timestamptz DEFAULT now()
);

-- subscriptions: merchant subscription history / plans
CREATE TABLE IF NOT EXISTS subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id uuid REFERENCES merchants(id) ON DELETE CASCADE,
  plan_name text,
  price numeric,
  status text DEFAULT 'active', -- 'active', 'cancelled', 'expired'
  start_at timestamptz DEFAULT now(),
  end_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- reports view: merchant summary (debts, payments, balance)
CREATE OR REPLACE VIEW merchant_financial_summary AS
SELECT
  m.id AS merchant_id,
  COALESCE(SUM(CASE WHEN t.type = 'debt' THEN t.amount ELSE 0 END), 0) AS total_debt,
  COALESCE(SUM(CASE WHEN t.type = 'payment' THEN t.amount ELSE 0 END), 0) AS total_payments,
  COALESCE(SUM(CASE WHEN t.type = 'debt' THEN t.amount ELSE 0 END), 0) - COALESCE(SUM(CASE WHEN t.type = 'payment' THEN t.amount ELSE 0 END), 0) AS current_balance
FROM merchants m
LEFT JOIN transactions t ON t.merchant_id = m.id
GROUP BY m.id;

-- helpful indexes for queries
CREATE INDEX IF NOT EXISTS transactions_merchant_idx ON transactions(merchant_id);
CREATE INDEX IF NOT EXISTS transactions_customer_idx ON transactions(customer_id);
CREATE INDEX IF NOT EXISTS wallets_merchant_idx ON wallets(merchant_id);

-- RPC function: add_transaction_and_update_wallet
-- This function inserts a transaction and updates the wallet balance atomically.
CREATE OR REPLACE FUNCTION public.add_transaction_and_update_wallet(
  p_merchant_id uuid,
  p_customer_id uuid,
  p_wallet_id uuid,
  p_amount numeric,
  p_type text,
  p_notes text DEFAULT NULL
) RETURNS TABLE(result_transaction_id uuid) LANGUAGE plpgsql AS $$
BEGIN
  IF p_type NOT IN ('debt','payment') THEN
    RAISE EXCEPTION 'Invalid type';
  END IF;

  -- Insert transaction
  INSERT INTO transactions (merchant_id, customer_id, wallet_id, amount, type, notes)
  VALUES (p_merchant_id, p_customer_id, p_wallet_id, p_amount, p_type, p_notes)
  RETURNING id INTO result_transaction_id;

  -- Update wallet balance: debts increase balance (money owed), payments decrease it (assumption)
  IF p_type = 'debt' THEN
    UPDATE wallets SET balance = balance + p_amount WHERE id = p_wallet_id;
  ELSE
    UPDATE wallets SET balance = balance - p_amount WHERE id = p_wallet_id;
  END IF;

  RETURN;
END;
$$;

-- Seed data (optional) — small sample records for testing
INSERT INTO profiles (phone, name, user_type, business_name)
SELECT '+966500000001', 'Admin', 'admin', 'Admin Shop'
WHERE NOT EXISTS (SELECT 1 FROM profiles WHERE phone = '+966500000001');

-- End of migration
