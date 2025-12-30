-- Moomingle Missing Tables Migration
-- Run this in your Supabase SQL Editor to create all missing tables

-- ============================================
-- 1. PROFILES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  phone TEXT,
  location TEXT,
  bio TEXT,
  avatar_url TEXT,
  is_verified BOOLEAN DEFAULT false,
  user_type TEXT CHECK (user_type IN ('buyer', 'seller', 'both')) DEFAULT 'buyer',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policies for profiles
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- ============================================
-- 2. FAVORITES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, listing_id)
);

-- Enable RLS
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Policies for favorites
CREATE POLICY "Users can view their own favorites"
  ON favorites FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can add favorites"
  ON favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove their favorites"
  ON favorites FOR DELETE
  USING (auth.uid() = user_id);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_listing_id ON favorites(listing_id);

-- ============================================
-- 3. PURCHASES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  buyer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  seller_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  purchase_price DECIMAL(10, 2) NOT NULL,
  payment_method TEXT CHECK (payment_method IN ('cash', 'bank_transfer', 'upi', 'other')),
  payment_status TEXT CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')) DEFAULT 'pending',
  transaction_id TEXT,
  notes TEXT,
  purchased_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

-- Enable RLS
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;

-- Policies for purchases
CREATE POLICY "Buyers can view their purchases"
  ON purchases FOR SELECT
  USING (auth.uid() = buyer_id);

CREATE POLICY "Sellers can view their sales"
  ON purchases FOR SELECT
  USING (auth.uid() = seller_id);

CREATE POLICY "Buyers can create purchases"
  ON purchases FOR INSERT
  WITH CHECK (auth.uid() = buyer_id);

CREATE POLICY "Buyers and sellers can update their purchases"
  ON purchases FOR UPDATE
  USING (auth.uid() = buyer_id OR auth.uid() = seller_id);

-- Indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_purchases_buyer_id ON purchases(buyer_id);
CREATE INDEX IF NOT EXISTS idx_purchases_seller_id ON purchases(seller_id);
CREATE INDEX IF NOT EXISTS idx_purchases_listing_id ON purchases(listing_id);

-- ============================================
-- 4. OFFERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  buyer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  seller_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  offer_amount DECIMAL(10, 2) NOT NULL,
  message TEXT,
  status TEXT CHECK (status IN ('pending', 'accepted', 'rejected', 'countered', 'withdrawn')) DEFAULT 'pending',
  counter_amount DECIMAL(10, 2),
  counter_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ
);

-- Enable RLS
ALTER TABLE offers ENABLE ROW LEVEL SECURITY;

-- Policies for offers
CREATE POLICY "Buyers can view their offers"
  ON offers FOR SELECT
  USING (auth.uid() = buyer_id);

CREATE POLICY "Sellers can view offers on their listings"
  ON offers FOR SELECT
  USING (auth.uid() = seller_id);

CREATE POLICY "Buyers can create offers"
  ON offers FOR INSERT
  WITH CHECK (auth.uid() = buyer_id);

CREATE POLICY "Buyers can update their offers"
  ON offers FOR UPDATE
  USING (auth.uid() = buyer_id);

CREATE POLICY "Sellers can update offers on their listings"
  ON offers FOR UPDATE
  USING (auth.uid() = seller_id);

-- Indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_offers_listing_id ON offers(listing_id);
CREATE INDEX IF NOT EXISTS idx_offers_buyer_id ON offers(buyer_id);
CREATE INDEX IF NOT EXISTS idx_offers_seller_id ON offers(seller_id);
CREATE INDEX IF NOT EXISTS idx_offers_status ON offers(status);

-- ============================================
-- 5. NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('match', 'message', 'offer', 'purchase', 'listing_update', 'system')),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  read_at TIMESTAMPTZ
);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Policies for notifications
CREATE POLICY "Users can view their own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "System can insert notifications"
  ON notifications FOR INSERT
  WITH CHECK (true);

-- Indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- ============================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for profiles
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for offers
CREATE TRIGGER update_offers_updated_at
  BEFORE UPDATE ON offers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEWS FOR ANALYTICS
-- ============================================

-- Note: The listings table uses seller_name (TEXT) not seller_id (UUID)
-- These views are commented out until listings table is migrated to use seller_id

-- View for buyer statistics (works with current schema)
CREATE OR REPLACE VIEW buyer_stats AS
SELECT 
  user_id as buyer_id,
  COUNT(DISTINCT id) as total_favorites,
  COUNT(DISTINCT listing_id) as unique_listings_favorited
FROM favorites
GROUP BY user_id;

-- TODO: Create seller_stats view after adding seller_id column to listings table
-- Migration needed:
-- ALTER TABLE listings ADD COLUMN seller_id UUID REFERENCES auth.users(id);
-- UPDATE listings SET seller_id = (SELECT id FROM profiles WHERE full_name = listings.seller_name) WHERE seller_name IS NOT NULL;

-- ============================================
-- GRANT PERMISSIONS
-- ============================================

-- Grant access to authenticated users
GRANT SELECT, INSERT, UPDATE, DELETE ON profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON favorites TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON purchases TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON offers TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON notifications TO authenticated;

-- Grant access to views
GRANT SELECT ON buyer_stats TO authenticated;

-- Note: seller_stats view will be created after listings table migration

-- ============================================
-- SAMPLE DATA (OPTIONAL)
-- ============================================

-- Uncomment to insert sample notification types documentation
-- INSERT INTO notifications (user_id, type, title, body, data) VALUES
-- (auth.uid(), 'system', 'Welcome to Moomingle!', 'Start browsing cattle listings now.', '{"action": "browse"}');
