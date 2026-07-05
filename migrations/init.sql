-- migrations/init.sql
-- Creates profiles table and common tables skeleton

-- Enable pgcrypto for gen_random_uuid() (Supabase projects typically have it)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- profiles table: links to auth.users
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  phone text NOT NULL,
  name text,
  user_type text NOT NULL DEFAULT 'customer', -- 'merchant' | 'customer' | 'admin'
  business_name text,
  created_at timestamptz DEFAULT now()
);

-- unique constraint on phone
CREATE UNIQUE INDEX IF NOT EXISTS profiles_phone_idx ON profiles(LOWER(phone));

-- Example additional tables (skeletons)
CREATE TABLE IF NOT EXISTS wallets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  name text,
  balance numeric DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id uuid REFERENCES profiles(id),
  customer_id uuid REFERENCES profiles(id),
  wallet_id uuid REFERENCES wallets(id),
  amount numeric NOT NULL,
  type text NOT NULL, -- 'debt' | 'payment'
  notes text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text,
  image_path text,
  url text,
  clicks int DEFAULT 0,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id),
  title text,
  body text,
  is_read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);
