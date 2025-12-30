#!/usr/bin/env python3
"""Check actual data in Supabase"""
import requests
import json

SUPABASE_URL = "https://igivbuexkliagpyakngf.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlnaXZidWV4a2xpYWdweWFrbmdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY2NDcxNTUsImV4cCI6MjA4MjIyMzE1NX0.hSubCrbjs5vxXBaA-gEKdcd2m2u5hKT0waQX4BIvEfg"

headers = {
    "apikey": SUPABASE_ANON_KEY,
    "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
}

print("📊 LISTINGS TABLE")
print("=" * 80)
response = requests.get(f"{SUPABASE_URL}/rest/v1/listings?select=*", headers=headers)
if response.status_code == 200:
    listings = response.json()
    print(f"Total listings: {len(listings)}")
    for listing in listings:
        print(f"\n  ID: {listing.get('id')}")
        print(f"  Name: {listing.get('name')}")
        print(f"  Breed: {listing.get('breed')}")
        print(f"  Price: ₹{listing.get('price'):,.0f}")
        print(f"  Location: {listing.get('location')}")
        print(f"  Verified: {listing.get('is_verified')}")
        print(f"  Status: {listing.get('status', 'N/A')}")
else:
    print(f"Error: {response.status_code}")

print("\n" + "=" * 80)
print("💬 CHATS TABLE")
print("=" * 80)
response = requests.get(f"{SUPABASE_URL}/rest/v1/chats?select=*", headers=headers)
if response.status_code == 200:
    chats = response.json()
    print(f"Total chats: {len(chats)}")
    if len(chats) == 0:
        print("  (No chats yet)")
else:
    print(f"Error: {response.status_code}")

print("\n" + "=" * 80)
print("📨 MESSAGES TABLE")
print("=" * 80)
response = requests.get(f"{SUPABASE_URL}/rest/v1/messages?select=*", headers=headers)
if response.status_code == 200:
    messages = response.json()
    print(f"Total messages: {len(messages)}")
    if len(messages) == 0:
        print("  (No messages yet)")
else:
    print(f"Error: {response.status_code}")
