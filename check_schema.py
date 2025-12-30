#!/usr/bin/env python3
"""Check actual table schemas in Supabase"""
import requests

SUPABASE_URL = "https://igivbuexkliagpyakngf.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlnaXZidWV4a2xpYWdweWFrbmdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY2NDcxNTUsImV4cCI6MjA4MjIyMzE1NX0.hSubCrbjs5vxXBaA-gEKdcd2m2u5hKT0waQX4BIvEfg"

headers = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
    "Content-Type": "application/json"
}

tables = ['listings', 'chats', 'messages', 'profiles', 'favorites', 'purchases', 'offers', 'notifications']

for table in tables:
    print(f"\n{'='*50}")
    print(f"🔍 {table.upper()} TABLE")
    print('='*50)
    
    url = f"{SUPABASE_URL}/rest/v1/{table}?select=*&limit=1"
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        data = response.json()
        if data:
            print("Columns:")
            for key in sorted(data[0].keys()):
                print(f"   • {key}")
        else:
            print("⚠️  Table exists but is empty (can't determine columns)")
    elif response.status_code == 404:
        print("❌ Table does not exist")
    else:
        print(f"❌ Error {response.status_code}: {response.text[:100]}")
