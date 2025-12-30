-- Migration: Add seller_id to listings table
-- Run this AFTER create_missing_tables.sql and AFTER you have user profiles

-- ============================================
-- ADD SELLER_ID COLUMN TO LISTINGS
-- ============================================

-- Add the seller_id column (nullable initially)
ALTER TABLE listings 
ADD COLUMN IF NOT EXISTS seller_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_listings_seller_id ON listings(seller_id);

-- ============================================
-- MIGRATE EXISTING DATA (OPTIONAL)
-- ============================================

-- If you want to link existing listings to users based on seller_name:
-- UPDATE listings 
-- SET seller_id = (
--   SELECT id FROM profiles 
--   WHERE profiles.full_name = listings.seller_name 
--   LIMIT 1
-- )
-- WHERE seller_name IS NOT NULL AND seller_id IS NULL;

-- ============================================
-- CREATE SELLER STATS VIEW
-- ============================================

-- Now we can create the seller_stats view
CREATE OR REPLACE VIEW seller_stats AS
SELECT 
  l.seller_id,
  COUNT(DISTINCT l.id) as total_listings,
  COUNT(DISTINCT f.id) as total_favorites,
  COUNT(DISTINCT p.id) as total_sales,
  COALESCE(SUM(p.purchase_price), 0) as total_revenue,
  COUNT(DISTINCT o.id) as total_offers
FROM listings l
LEFT JOIN favorites f ON l.id = f.listing_id
LEFT JOIN purchases p ON l.id = p.listing_id AND p.payment_status = 'completed'
LEFT JOIN offers o ON l.id = o.listing_id
WHERE l.seller_id IS NOT NULL
GROUP BY l.seller_id;

-- Grant access
GRANT SELECT ON seller_stats TO authenticated;

-- ============================================
-- UPDATE RLS POLICIES (OPTIONAL)
-- ============================================

-- Add policy for sellers to manage their own listings
-- CREATE POLICY "Sellers can update their own listings"
--   ON listings FOR UPDATE
--   USING (auth.uid() = seller_id);

-- CREATE POLICY "Sellers can delete their own listings"
--   ON listings FOR DELETE
--   USING (auth.uid() = seller_id);
