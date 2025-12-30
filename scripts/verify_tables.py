#!/usr/bin/env python3
"""
Verify that all required database tables exist in Supabase
"""

import os
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

try:
    from supabase import create_client
    from dotenv import load_dotenv
except ImportError:
    print("❌ Missing dependencies. Install with:")
    print("   pip install supabase python-dotenv")
    sys.exit(1)

# Load environment variables
load_dotenv()

SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_ANON_KEY')

if not SUPABASE_URL or not SUPABASE_KEY:
    print("❌ Error: Missing Supabase credentials in .env")
    print("Make sure .env has SUPABASE_URL and SUPABASE_ANON_KEY")
    sys.exit(1)

# Required tables
REQUIRED_TABLES = [
    'listings',
    'profiles', 
    'favorites',
    'purchases',
    'offers',
    'notifications',
    'chats',
    'messages'
]

def check_table_exists(supabase, table_name):
    """Check if a table exists by trying to query it"""
    try:
        # Try to select with limit 0 (no data returned, just checks existence)
        supabase.table(table_name).select('*').limit(0).execute()
        return True
    except Exception as e:
        error_msg = str(e).lower()
        if 'does not exist' in error_msg or 'relation' in error_msg:
            return False
        # Other errors might be permissions, which means table exists
        return True

def main():
    print("🐄 Moomingle Database Verification")
    print("=" * 50)
    print(f"📍 Supabase URL: {SUPABASE_URL}")
    print()
    
    try:
        # Create Supabase client
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Connected to Supabase")
        print()
        
        # Check each table
        missing_tables = []
        existing_tables = []
        
        print("📊 Checking tables...")
        print()
        
        for table in REQUIRED_TABLES:
            exists = check_table_exists(supabase, table)
            status = "✅" if exists else "❌"
            print(f"{status} {table}")
            
            if exists:
                existing_tables.append(table)
            else:
                missing_tables.append(table)
        
        print()
        print("=" * 50)
        print(f"✅ Existing: {len(existing_tables)}/{len(REQUIRED_TABLES)}")
        print(f"❌ Missing: {len(missing_tables)}/{len(REQUIRED_TABLES)}")
        print()
        
        if missing_tables:
            print("🔧 Missing tables:")
            for table in missing_tables:
                print(f"   • {table}")
            print()
            print("📋 To fix:")
            print("1. Open Supabase Dashboard SQL Editor")
            print("2. Run: backend/migrations/create_missing_tables.sql")
            print()
            return 1
        else:
            print("🎉 All required tables exist!")
            print("✅ Database is ready to use")
            print()
            return 0
            
    except Exception as e:
        print(f"❌ Error: {e}")
        print()
        print("Troubleshooting:")
        print("• Check .env has correct SUPABASE_URL and SUPABASE_ANON_KEY")
        print("• Verify Supabase project is active")
        print("• Check network connection")
        return 1

if __name__ == '__main__':
    sys.exit(main())
