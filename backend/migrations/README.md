# Database Migrations

## Quick Fix for Missing Tables

### Problem
Your app was using placeholder credentials in `.env` instead of real ones from `.env.development`, and several database tables were missing.

### Solution Applied

#### 1. Fixed Environment Configuration ✅
```bash
# The .env file now has REAL credentials copied from .env.development
SUPABASE_URL=https://igivbuexkliagpyakngf.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### 2. Created Missing Tables Migration ✅
Run `create_missing_tables_fixed.sql` in Supabase SQL Editor to create:

| Table | Purpose | Status |
|-------|---------|--------|
| `profiles` | User profiles with verification badges | 🆕 New |
| `favorites` | Saved/liked listings | 🆕 New |
| `purchases` | Transaction history & payment tracking | 🆕 New |
| `offers` | Bidding/negotiation system | 🆕 New |
| `notifications` | Push alerts & in-app notifications | 🆕 New |

### How to Run the Migration

#### Step 1: Create Core Tables (Required)
1. Open [Supabase Dashboard](https://supabase.com/dashboard/project/igivbuexkliagpyakngf)
2. Click **SQL Editor** in left sidebar
3. Click **New Query**
4. Copy entire contents of `create_missing_tables.sql`
5. Paste and click **Run**
6. Verify success (should see "Success. No rows returned")

#### Step 2: Add seller_id to listings (Optional - for future features)
This step links listings to user accounts. Run this later when you want:
- Sellers to manage their own listings
- Better analytics per seller
- User-based permissions

1. In SQL Editor, create another **New Query**
2. Copy contents of `add_seller_id_to_listings.sql`
3. Paste and click **Run**

**Note:** Step 2 is optional. Your app works fine with just `seller_name` for now.

#### Option 2: Command Line
```bash
# Run the setup script
./scripts/setup_database.sh

# Or manually with psql (if you have service_role key)
psql "postgresql://postgres:[PASSWORD]@db.igivbuexkliagpyakngf.supabase.co:5432/postgres" \
  -f backend/migrations/create_missing_tables.sql

# Optional: Add seller_id column later
psql "postgresql://postgres:[PASSWORD]@db.igivbuexkliagpyakngf.supabase.co:5432/postgres" \
  -f backend/migrations/add_seller_id_to_listings.sql
```

### What Gets Created

#### Tables with RLS Policies
All tables have Row Level Security enabled with proper policies:
- Users can only see/edit their own data
- Public data is viewable by everyone
- Sellers can manage their listings
- Buyers can manage their purchases

#### Indexes for Performance
Optimized queries on:
- User IDs (fast lookups)
- Listing IDs (fast joins)
- Status fields (fast filtering)
- Timestamps (fast sorting)

#### Automatic Triggers
- `updated_at` timestamps auto-update on changes
- Cascading deletes (delete user → delete their data)

#### Analytics Views
- `buyer_stats` - Favorites and activity per buyer ✅
- `seller_stats` - Total listings, sales, revenue per seller (requires Step 2 migration)

### Verify Migration Success

```bash
# Check if tables exist
python3 check_supabase.py

# Or check in Supabase Dashboard
# Go to: Table Editor → Should see all 5 new tables
```

### Mock Data vs Real Data

Your app is **NOT using mock data** - it's using real Supabase with fallbacks:

| Feature | Data Source | Fallback |
|---------|-------------|----------|
| Listings | Supabase `listings` table | Mock data if DB fails |
| Chats | Supabase `chats` table | Empty list if DB fails |
| Auth | Supabase Auth | Anonymous mode |
| Profiles | Supabase `profiles` table | Demo profile if not logged in |

The `ENABLE_MOCK_DATA=true` flag only enables fallbacks for resilience, not primary data source.

### Next Steps

1. ✅ Run the migration SQL
2. ✅ Verify tables exist in Supabase Dashboard
3. ✅ Test the app - it should now work fully
4. 🔄 Optional: Populate with sample data using `data_import/import_csv.py`

### Troubleshooting

**Error: "relation already exists"**
- Tables already created, safe to ignore
- Or drop tables first: `DROP TABLE IF EXISTS profiles CASCADE;`

**Error: "permission denied"**
- Make sure you're using the SQL Editor in Supabase Dashboard
- Don't use the anon key for migrations (use dashboard)

**Error: "foreign key constraint"**
- Make sure `listings` table exists first
- Check that `auth.users` table exists (should be automatic)

### Files Changed

```
✅ .env - Now has real credentials
✅ backend/migrations/create_missing_tables.sql - New migration
✅ scripts/setup_database.sh - Setup helper script
✅ backend/migrations/README.md - This file
```

### Support

If you encounter issues:
1. Check Supabase Dashboard → Logs
2. Run `python3 check_supabase.py` for diagnostics
3. Verify `.env` has correct credentials
4. Check that migration ran successfully in SQL Editor
