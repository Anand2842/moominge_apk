#!/usr/bin/env python3
"""Check Supabase database connection and schema"""
import os
import requests
import json

# Read from .env.development
SUPABASE_URL = "https://igivbuexkliagpyakngf.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlnaXZidWV4a2xpYWdweWFrbmdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY2NDcxNTUsImV4cCI6MjA4MjIyMzE1NX0.hSubCrbjs5vxXBaA-gEKdcd2m2u5hKT0waQX4BIvEfg"

headers = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
    "Content-Type": "application/json"
}

print("🔍 Checking Supabase Connection...")
print(f"URL: {SUPABASE_URL}")
print()

# Check tables
tables_to_check = ['listings', 'profiles', 'chats', 'messages', 'favorites', 'purchases', 'offers', 'notifications']

for table in tables_to_check:
    try:
        url = f"{SUPABASE_URL}/rest/v1/{table}?select=*&limit=1"
        response = requests.get(url, headers=headers)
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ {table:20} - EXISTS ({len(data)} sample records)")
        elif response.status_code == 404:
            print(f"❌ {table:20} - NOT FOUND (table doesn't exist)")
        elif response.status_code == 401:
            print(f"🔒 {table:20} - UNAUTHORIZED (RLS policy blocking)")
        else:
            print(f"⚠️  {table:20} - ERROR {response.status_code}: {response.text[:100]}")
    except Exception as e:
        print(f"❌ {table:20} - ERROR: {str(e)[:100]}")

print()
print("🔍 Checking for any existing tables...")
try:
    # Try to get schema info via PostgREST
    url = f"{SUPABASE_URL}/rest/v1/"
    response = requests.get(url, headers=headers)
    print(f"API Status: {response.status_code}")
except Exception as e:
    print(f"Error: {e}")
