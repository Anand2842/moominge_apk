-- ============================================
-- MOOMINGLE COMPLETE DATABASE MIGRATION V3
-- ============================================
-- This migration DROPS and RECREATES empty tables
-- Run this in your Supabase SQL Editor
-- WARNING: This will delete data in empty tables!

-- ============================================
-- STEP 1: ADD MISSING COLUMNS TO LISTINGS TABLE
-- ============================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'listings' AND column_name = 'seller_id'
  ) THEN
    ALTER TABLE listings ADD COLUMN seller_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;
    RAISE NOTICE '✅ Added seller_id column to listings table';
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'listings' AND column_name = 'status'
  ) THEN
    ALTER TABLE listings ADD COLUMN status TEXT CHECK (status IN ('active', 'sold', 'inactive')) DEFAULT 'active';
    RAISE NOTICE '✅ Added status column to listings table';
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_listings_seller_id ON listings(seller_id);
CREATE INDEX IF NOT EXISTS idx_listings_status ON listings(status);

-- ============================================
-- STEP 2: DROP AND RECREATE EMPTY TABLES
-- ============================================

-- Drop tables in correct order (respecting foreign keys)
DROP TABLE IF EXISTS error_logs CASCADE;
DROP TABLE IF EXISTS analytics_events CASCADE;
DROP TABLE IF EXISTS muzzle_prints CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS offers CASCADE;
DROP TABLE IF EXISTS purchases CASCADE;
DROP TABLE IF EXISTS favorites CASCADE;
DROP TABLE IF EXISTS chats CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- ============================================
-- STEP 3: CREATE PROFILES TABLE
-- ============================================

CREATE TABLE profiles (
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

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

-- ============================================
-- STEP 4: CREATE CHATS TABLE
-- ============================================

CREATE TABLE chats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  buyer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  seller_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  listing_id UUID REFERENCES listings(id) ON DELETE SET NULL,
  listing_name TEXT NOT NULL,
  seller_name TEXT NOT NULL,
  last_message TEXT,
  last_message_time TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own chats"
  ON chats FOR SELECT TO authenticated
  USING (auth.uid() = buyer_id OR auth.uid() = seller_id);

CREATE POLICY "Authenticated users can create chats"
  ON chats FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = buyer_id OR auth.uid() = seller_id);

CREATE POLICY "Chat participants can update chats"
  ON chats FOR UPDATE TO authenticated
  USING (auth.uid() = buyer_id OR auth.uid() = seller_id)
  WITH CHECK (auth.uid() = buyer_id OR auth.uid() = seller_id);

CREATE INDEX idx_chats_buyer_id ON chats(buyer_id);
CREATE INDEX idx_chats_seller_id ON chats(seller_id);
CREATE INDEX idx_chats_listing_id ON chats(listing_id);
CREATE INDEX idx_chats_last_message_time ON chats(last_message_time DESC);

-- ============================================
-- STEP 5: CREATE MESSAGES TABLE
-- ============================================

CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view messages in their chats"
  ON messages FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM chats
      WHERE chats.id = messages.chat_id
      AND (chats.buyer_id = auth.uid() OR chats.seller_id = auth.uid())
    )
  );

CREATE POLICY "Users can send messages in their chats"
  ON messages FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
      SELECT 1 FROM chats
      WHERE chats.id = messages.chat_id
      AND (chats.buyer_id = auth.uid() OR chats.seller_id = auth.uid())
    )
  );

CREATE POLICY "Users can update their own messages"
  ON messages FOR UPDATE TO authenticated
  USING (auth.uid() = sender_id)
  WITH CHECK (auth.uid() = sender_id);

CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- ============================================
-- STEP 6: CREATE FAVORITES TABLE
-- ============================================

CREATE TABLE favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, listing_id)
);

ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own favorites"
  ON favorites FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can add favorites"
  ON favorites FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove their favorites"
  ON favorites FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX idx_favorites_user_id ON favorites(user_id);
CREATE INDEX idx_favorites_listing_id ON favorites(listing_id);

-- ============================================
-- STEP 7: CREATE PURCHASES TABLE
-- ============================================

CREATE TABLE purchases (
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

ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Buyers can view their purchases"
  ON purchases FOR SELECT USING (auth.uid() = buyer_id);

CREATE POLICY "Sellers can view their sales"
  ON purchases FOR SELECT USING (auth.uid() = seller_id);

CREATE POLICY "Buyers can create purchases"
  ON purchases FOR INSERT WITH CHECK (auth.uid() = buyer_id);

CREATE POLICY "Buyers and sellers can update their purchases"
  ON purchases FOR UPDATE USING (auth.uid() = buyer_id OR auth.uid() = seller_id);

CREATE INDEX idx_purchases_buyer_id ON purchases(buyer_id);
CREATE INDEX idx_purchases_seller_id ON purchases(seller_id);
CREATE INDEX idx_purchases_listing_id ON purchases(listing_id);

-- ============================================
-- STEP 8: CREATE OFFERS TABLE
-- ============================================

CREATE TABLE offers (
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

ALTER TABLE offers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Buyers can view their offers"
  ON offers FOR SELECT USING (auth.uid() = buyer_id);

CREATE POLICY "Sellers can view offers on their listings"
  ON offers FOR SELECT USING (auth.uid() = seller_id);

CREATE POLICY "Buyers can create offers"
  ON offers FOR INSERT WITH CHECK (auth.uid() = buyer_id);

CREATE POLICY "Buyers can update their offers"
  ON offers FOR UPDATE USING (auth.uid() = buyer_id);

CREATE POLICY "Sellers can update offers on their listings"
  ON offers FOR UPDATE USING (auth.uid() = seller_id);

CREATE INDEX idx_offers_listing_id ON offers(listing_id);
CREATE INDEX idx_offers_buyer_id ON offers(buyer_id);
CREATE INDEX idx_offers_seller_id ON offers(seller_id);
CREATE INDEX idx_offers_status ON offers(status);

-- ============================================
-- STEP 9: CREATE NOTIFICATIONS TABLE
-- ============================================

CREATE TABLE notifications (
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

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications"
  ON notifications FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications"
  ON notifications FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "System can insert notifications"
  ON notifications FOR INSERT WITH CHECK (true);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- ============================================
-- STEP 10: CREATE MUZZLE PRINTS TABLE
-- ============================================

CREATE TABLE muzzle_prints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  hash TEXT,
  verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(listing_id)
);

ALTER TABLE muzzle_prints ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public muzzle prints are viewable"
  ON muzzle_prints FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert muzzle prints"
  ON muzzle_prints FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Authenticated users can update muzzle prints"
  ON muzzle_prints FOR UPDATE TO authenticated USING (true);

CREATE INDEX idx_muzzle_prints_listing_id ON muzzle_prints(listing_id);

-- ============================================
-- STEP 11: CREATE ANALYTICS EVENTS TABLE
-- ============================================

CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  event_type TEXT NOT NULL CHECK (event_type IN (
    'listing_view', 'listing_like', 'listing_pass', 'listing_share',
    'chat_started', 'message_sent', 'offer_made', 'purchase_completed',
    'profile_view', 'search_performed', 'filter_applied',
    'breed_scan', 'muzzle_capture', 'boost_purchased'
  )),
  event_data JSONB,
  session_id TEXT,
  device_info JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own analytics events"
  ON analytics_events FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can view their own analytics events"
  ON analytics_events FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE INDEX idx_analytics_user_id ON analytics_events(user_id);
CREATE INDEX idx_analytics_event_type ON analytics_events(event_type);
CREATE INDEX idx_analytics_created_at ON analytics_events(created_at DESC);
CREATE INDEX idx_analytics_session_id ON analytics_events(session_id);

-- ============================================
-- STEP 12: CREATE ERROR LOGS TABLE
-- ============================================

CREATE TABLE error_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  error_type TEXT NOT NULL,
  error_message TEXT NOT NULL,
  stack_trace TEXT,
  context JSONB,
  severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')) DEFAULT 'medium',
  resolved BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own error logs"
  ON error_logs FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can view their own error logs"
  ON error_logs FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE INDEX idx_error_logs_user_id ON error_logs(user_id);
CREATE INDEX idx_error_logs_severity ON error_logs(severity);
CREATE INDEX idx_error_logs_resolved ON error_logs(resolved);
CREATE INDEX idx_error_logs_created_at ON error_logs(created_at DESC);

-- ============================================
-- STEP 13: LISTINGS TABLE RLS POLICIES
-- ============================================

ALTER TABLE listings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public listings are viewable by everyone" ON listings;
DROP POLICY IF EXISTS "Authenticated users can insert listings" ON listings;
DROP POLICY IF EXISTS "Sellers can update their own listings" ON listings;
DROP POLICY IF EXISTS "Sellers can delete their own listings" ON listings;

CREATE POLICY "Public listings are viewable by everyone"
  ON listings FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert listings"
  ON listings FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = seller_id OR seller_id IS NULL);

CREATE POLICY "Sellers can update their own listings"
  ON listings FOR UPDATE TO authenticated
  USING (auth.uid() = seller_id OR seller_id IS NULL)
  WITH CHECK (auth.uid() = seller_id OR seller_id IS NULL);

CREATE POLICY "Sellers can delete their own listings"
  ON listings FOR DELETE TO authenticated
  USING (auth.uid() = seller_id OR seller_id IS NULL);

-- ============================================
-- STEP 14: CREATE HELPER FUNCTIONS
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_chats_updated_at ON chats;
CREATE TRIGGER update_chats_updated_at
  BEFORE UPDATE ON chats
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_offers_updated_at ON offers;
CREATE TRIGGER update_offers_updated_at
  BEFORE UPDATE ON offers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE FUNCTION track_listing_view(
  p_listing_id UUID,
  p_session_id TEXT DEFAULT NULL
)
RETURNS void AS $$
BEGIN
  INSERT INTO analytics_events (user_id, event_type, event_data, session_id)
  VALUES (
    auth.uid(),
    'listing_view',
    jsonb_build_object('listing_id', p_listing_id),
    p_session_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_user_engagement(p_user_id UUID)
RETURNS TABLE (
  total_views BIGINT,
  total_likes BIGINT,
  total_chats BIGINT,
  total_offers BIGINT,
  engagement_score NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(DISTINCT CASE WHEN event_type = 'listing_view' THEN id END),
    COUNT(DISTINCT CASE WHEN event_type = 'listing_like' THEN id END),
    COUNT(DISTINCT CASE WHEN event_type = 'chat_started' THEN id END),
    COUNT(DISTINCT CASE WHEN event_type = 'offer_made' THEN id END),
    (
      COUNT(DISTINCT CASE WHEN event_type = 'listing_view' THEN id END) * 1 +
      COUNT(DISTINCT CASE WHEN event_type = 'listing_like' THEN id END) * 2 +
      COUNT(DISTINCT CASE WHEN event_type = 'chat_started' THEN id END) * 5 +
      COUNT(DISTINCT CASE WHEN event_type = 'offer_made' THEN id END) * 10
    )::NUMERIC
  FROM analytics_events
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- STEP 15: CREATE ANALYTICS VIEWS
-- ============================================

DROP VIEW IF EXISTS daily_active_users;
DROP VIEW IF EXISTS popular_listings;
DROP VIEW IF EXISTS seller_performance;
DROP VIEW IF EXISTS buyer_stats;
DROP VIEW IF EXISTS listing_stats;

CREATE VIEW daily_active_users AS
SELECT 
  DATE(created_at) as date,
  COUNT(DISTINCT user_id) as active_users
FROM analytics_events
WHERE user_id IS NOT NULL
GROUP BY DATE(created_at)
ORDER BY date DESC;

CREATE VIEW popular_listings AS
SELECT 
  l.id,
  l.name,
  l.breed,
  l.price,
  COUNT(DISTINCT CASE WHEN ae.event_type = 'listing_view' THEN ae.id END) as views,
  COUNT(DISTINCT CASE WHEN ae.event_type = 'listing_like' THEN ae.id END) as likes,
  COUNT(DISTINCT f.id) as favorites,
  COUNT(DISTINCT o.id) as offers
FROM listings l
LEFT JOIN analytics_events ae ON (ae.event_data->>'listing_id')::uuid = l.id
LEFT JOIN favorites f ON f.listing_id = l.id
LEFT JOIN offers o ON o.listing_id = l.id
GROUP BY l.id, l.name, l.breed, l.price
ORDER BY views DESC, likes DESC;

CREATE VIEW seller_performance AS
SELECT 
  l.seller_id,
  p.full_name as seller_name,
  COUNT(DISTINCT l.id) as total_listings,
  COUNT(DISTINCT CASE WHEN COALESCE(l.status, 'active') = 'active' THEN l.id END) as active_listings,
  COUNT(DISTINCT f.id) as total_favorites,
  COUNT(DISTINCT o.id) as total_offers,
  COUNT(DISTINCT pur.id) as total_sales,
  COALESCE(SUM(pur.purchase_price), 0) as total_revenue
FROM listings l
LEFT JOIN profiles p ON p.id = l.seller_id
LEFT JOIN favorites f ON f.listing_id = l.id
LEFT JOIN offers o ON o.listing_id = l.id
LEFT JOIN purchases pur ON pur.listing_id = l.id AND pur.payment_status = 'completed'
WHERE l.seller_id IS NOT NULL
GROUP BY l.seller_id, p.full_name;

CREATE VIEW buyer_stats AS
SELECT 
  user_id as buyer_id,
  COUNT(DISTINCT id) as total_favorites,
  COUNT(DISTINCT listing_id) as unique_listings_favorited
FROM favorites
GROUP BY user_id;

CREATE VIEW listing_stats AS
SELECT 
  l.id as listing_id,
  l.name as listing_name,
  l.breed,
  l.price,
  COUNT(DISTINCT f.id) as favorite_count,
  COUNT(DISTINCT o.id) as offer_count,
  MAX(o.offer_amount) as highest_offer,
  CASE WHEN p.id IS NOT NULL THEN true ELSE false END as is_sold
FROM listings l
LEFT JOIN favorites f ON l.id = f.listing_id
LEFT JOIN offers o ON l.id = o.listing_id
LEFT JOIN purchases p ON l.id = p.listing_id AND p.payment_status = 'completed'
GROUP BY l.id, l.name, l.breed, l.price, p.id;

-- ============================================
-- STEP 16: GRANT PERMISSIONS
-- ============================================

GRANT SELECT, INSERT, UPDATE, DELETE ON profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON chats TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON messages TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON favorites TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON purchases TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON offers TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON notifications TO authenticated;
GRANT SELECT, INSERT, UPDATE ON muzzle_prints TO authenticated;
GRANT SELECT, INSERT ON analytics_events TO authenticated;
GRANT SELECT, INSERT ON error_logs TO authenticated;

GRANT SELECT ON daily_active_users TO authenticated;
GRANT SELECT ON popular_listings TO authenticated;
GRANT SELECT ON seller_performance TO authenticated;
GRANT SELECT ON buyer_stats TO authenticated;
GRANT SELECT ON listing_stats TO authenticated;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '✅ MIGRATION V3 COMPLETED SUCCESSFULLY!';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Tables recreated:';
  RAISE NOTICE '   • profiles, chats, messages, favorites';
  RAISE NOTICE '   • purchases, offers, notifications';
  RAISE NOTICE '   • muzzle_prints, analytics_events, error_logs';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Listings table updated:';
  RAISE NOTICE '   • Added seller_id column';
  RAISE NOTICE '   • Added status column';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 RLS policies enabled on all tables';
  RAISE NOTICE '📈 Analytics views created';
  RAISE NOTICE '⚙️  Helper functions created';
  RAISE NOTICE '';
  RAISE NOTICE '🎉 Your Moomingle database is ready!';
END $$;
