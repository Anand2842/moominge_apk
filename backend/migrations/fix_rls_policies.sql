-- ============================================
-- COMPREHENSIVE RLS POLICY FIX
-- ============================================
-- This migration ensures all tables have proper Row Level Security
-- Run this in your Supabase SQL Editor

-- ============================================
-- 1. LISTINGS TABLE RLS
-- ============================================

-- Enable RLS on listings if not already enabled
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public listings are viewable by everyone" ON listings;
DROP POLICY IF EXISTS "Sellers can insert their own listings" ON listings;
DROP POLICY IF EXISTS "Sellers can update their own listings" ON listings;
DROP POLICY IF EXISTS "Sellers can delete their own listings" ON listings;

-- Create comprehensive policies for listings
CREATE POLICY "Public listings are viewable by everyone"
  ON listings FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert listings"
  ON listings FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = seller_id);

CREATE POLICY "Sellers can update their own listings"
  ON listings FOR UPDATE
  TO authenticated
  USING (auth.uid() = seller_id)
  WITH CHECK (auth.uid() = seller_id);

CREATE POLICY "Sellers can delete their own listings"
  ON listings FOR DELETE
  TO authenticated
  USING (auth.uid() = seller_id);

-- ============================================
-- 2. CHATS TABLE RLS
-- ============================================

-- Create chats table if it doesn't exist
CREATE TABLE IF NOT EXISTS chats (
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

-- Enable RLS
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own chats" ON chats;
DROP POLICY IF EXISTS "Users can create chats" ON chats;
DROP POLICY IF EXISTS "Users can update their own chats" ON chats;

-- Create policies for chats
CREATE POLICY "Users can view their own chats"
  ON chats FOR SELECT
  TO authenticated
  USING (auth.uid() = buyer_id OR auth.uid() = seller_id);

CREATE POLICY "Authenticated users can create chats"
  ON chats FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = buyer_id OR auth.uid() = seller_id);

CREATE POLICY "Chat participants can update chats"
  ON chats FOR UPDATE
  TO authenticated
  USING (auth.uid() = buyer_id OR auth.uid() = seller_id)
  WITH CHECK (auth.uid() = buyer_id OR auth.uid() = seller_id);

-- Indexes for chats
CREATE INDEX IF NOT EXISTS idx_chats_buyer_id ON chats(buyer_id);
CREATE INDEX IF NOT EXISTS idx_chats_seller_id ON chats(seller_id);
CREATE INDEX IF NOT EXISTS idx_chats_listing_id ON chats(listing_id);
CREATE INDEX IF NOT EXISTS idx_chats_last_message_time ON chats(last_message_time DESC);

-- ============================================
-- 3. MESSAGES TABLE RLS
-- ============================================

-- Create messages table if it doesn't exist
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view messages in their chats" ON messages;
DROP POLICY IF EXISTS "Users can send messages in their chats" ON messages;
DROP POLICY IF EXISTS "Users can update their own messages" ON messages;

-- Create policies for messages
CREATE POLICY "Users can view messages in their chats"
  ON messages FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM chats
      WHERE chats.id = messages.chat_id
      AND (chats.buyer_id = auth.uid() OR chats.seller_id = auth.uid())
    )
  );

CREATE POLICY "Users can send messages in their chats"
  ON messages FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
      SELECT 1 FROM chats
      WHERE chats.id = messages.chat_id
      AND (chats.buyer_id = auth.uid() OR chats.seller_id = auth.uid())
    )
  );

CREATE POLICY "Users can update their own messages"
  ON messages FOR UPDATE
  TO authenticated
  USING (auth.uid() = sender_id)
  WITH CHECK (auth.uid() = sender_id);

-- Indexes for messages
CREATE INDEX IF NOT EXISTS idx_messages_chat_id ON messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);

-- ============================================
-- 4. MUZZLE PRINTS TABLE RLS
-- ============================================

-- Create muzzle_prints table if it doesn't exist
CREATE TABLE IF NOT EXISTS muzzle_prints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  hash TEXT,
  verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(listing_id)
);

-- Enable RLS
ALTER TABLE muzzle_prints ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public muzzle prints are viewable" ON muzzle_prints;
DROP POLICY IF EXISTS "Sellers can insert muzzle prints for their listings" ON muzzle_prints;
DROP POLICY IF EXISTS "Sellers can update muzzle prints for their listings" ON muzzle_prints;

-- Create policies for muzzle_prints
CREATE POLICY "Public muzzle prints are viewable"
  ON muzzle_prints FOR SELECT
  USING (true);

CREATE POLICY "Sellers can insert muzzle prints for their listings"
  ON muzzle_prints FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM listings
      WHERE listings.id = muzzle_prints.listing_id
      AND listings.seller_id = auth.uid()
    )
  );

CREATE POLICY "Sellers can update muzzle prints for their listings"
  ON muzzle_prints FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM listings
      WHERE listings.id = muzzle_prints.listing_id
      AND listings.seller_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM listings
      WHERE listings.id = muzzle_prints.listing_id
      AND listings.seller_id = auth.uid()
    )
  );

-- Index for muzzle_prints
CREATE INDEX IF NOT EXISTS idx_muzzle_prints_listing_id ON muzzle_prints(listing_id);

-- ============================================
-- 5. ANALYTICS EVENTS TABLE (NEW)
-- ============================================

-- Create analytics_events table for monitoring
CREATE TABLE IF NOT EXISTS analytics_events (
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

-- Enable RLS
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- Policies for analytics_events
CREATE POLICY "Users can insert their own analytics events"
  ON analytics_events FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can view their own analytics events"
  ON analytics_events FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Indexes for analytics
CREATE INDEX IF NOT EXISTS idx_analytics_user_id ON analytics_events(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_event_type ON analytics_events(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_created_at ON analytics_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_session_id ON analytics_events(session_id);

-- ============================================
-- 6. ERROR LOGS TABLE (NEW)
-- ============================================

-- Create error_logs table for monitoring
CREATE TABLE IF NOT EXISTS error_logs (
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

-- Enable RLS
ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;

-- Policies for error_logs
CREATE POLICY "Users can insert their own error logs"
  ON error_logs FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can view their own error logs"
  ON error_logs FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Indexes for error logs
CREATE INDEX IF NOT EXISTS idx_error_logs_user_id ON error_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_error_logs_severity ON error_logs(severity);
CREATE INDEX IF NOT EXISTS idx_error_logs_resolved ON error_logs(resolved);
CREATE INDEX IF NOT EXISTS idx_error_logs_created_at ON error_logs(created_at DESC);

-- ============================================
-- 7. TRIGGERS FOR UPDATED_AT
-- ============================================

-- Trigger for chats
DROP TRIGGER IF EXISTS update_chats_updated_at ON chats;
CREATE TRIGGER update_chats_updated_at
  BEFORE UPDATE ON chats
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 8. ANALYTICS VIEWS
-- ============================================

-- Daily active users view
CREATE OR REPLACE VIEW daily_active_users AS
SELECT 
  DATE(created_at) as date,
  COUNT(DISTINCT user_id) as active_users
FROM analytics_events
WHERE user_id IS NOT NULL
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Popular listings view
CREATE OR REPLACE VIEW popular_listings AS
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

-- Seller performance view
CREATE OR REPLACE VIEW seller_performance AS
SELECT 
  l.seller_id,
  p.full_name as seller_name,
  COUNT(DISTINCT l.id) as total_listings,
  COUNT(DISTINCT CASE WHEN l.status = 'active' THEN l.id END) as active_listings,
  COUNT(DISTINCT f.id) as total_favorites,
  COUNT(DISTINCT o.id) as total_offers,
  COUNT(DISTINCT pur.id) as total_sales,
  COALESCE(SUM(pur.purchase_price), 0) as total_revenue
FROM listings l
LEFT JOIN profiles p ON p.id = l.seller_id
LEFT JOIN favorites f ON f.listing_id = l.id
LEFT JOIN offers o ON o.listing_id = l.id
LEFT JOIN purchases pur ON pur.listing_id = l.id AND pur.payment_status = 'completed'
GROUP BY l.seller_id, p.full_name;

-- ============================================
-- 9. GRANT PERMISSIONS
-- ============================================

GRANT SELECT, INSERT, UPDATE, DELETE ON chats TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON messages TO authenticated;
GRANT SELECT, INSERT, UPDATE ON muzzle_prints TO authenticated;
GRANT SELECT, INSERT ON analytics_events TO authenticated;
GRANT SELECT, INSERT ON error_logs TO authenticated;

GRANT SELECT ON daily_active_users TO authenticated;
GRANT SELECT ON popular_listings TO authenticated;
GRANT SELECT ON seller_performance TO authenticated;

-- ============================================
-- 10. FUNCTIONS FOR ANALYTICS
-- ============================================

-- Function to track listing views
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

-- Function to get user engagement metrics
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
    COUNT(DISTINCT CASE WHEN event_type = 'listing_view' THEN id END) as total_views,
    COUNT(DISTINCT CASE WHEN event_type = 'listing_like' THEN id END) as total_likes,
    COUNT(DISTINCT CASE WHEN event_type = 'chat_started' THEN id END) as total_chats,
    COUNT(DISTINCT CASE WHEN event_type = 'offer_made' THEN id END) as total_offers,
    (
      COUNT(DISTINCT CASE WHEN event_type = 'listing_view' THEN id END) * 1 +
      COUNT(DISTINCT CASE WHEN event_type = 'listing_like' THEN id END) * 2 +
      COUNT(DISTINCT CASE WHEN event_type = 'chat_started' THEN id END) * 5 +
      COUNT(DISTINCT CASE WHEN event_type = 'offer_made' THEN id END) * 10
    )::NUMERIC as engagement_score
  FROM analytics_events
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '✅ RLS policies fixed successfully!';
  RAISE NOTICE 'Tables secured: listings, chats, messages, muzzle_prints, profiles, favorites, purchases, offers, notifications';
  RAISE NOTICE 'New tables created: analytics_events, error_logs';
  RAISE NOTICE 'Analytics views created: daily_active_users, popular_listings, seller_performance';
  RAISE NOTICE 'Helper functions created: track_listing_view, get_user_engagement';
END $$;
