#!/usr/bin/env python3
"""Check the actual schema of the listings table"""

import os
from supabase import create_client
from dotenv import load_dotenv

load_dotenv()

supabase = create_client(
    os.getenv('SUPABASE_URL'),
    os.getenv('SUPABASE_ANON_KEY')
)

# Get a sample listing to see the structure
result = supabase.table('listings').select('*').limit(1).execute()

if result.data:
    print("📋 Listings table columns:")
    for key in result.data[0].keys():
        print(f"  • {key}")
else:
    print("No data in listings table")
