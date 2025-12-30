#!/bin/bash
# Moomingle Database Setup Script
# This script helps you set up the missing database tables

set -e

echo "🐄 Moomingle Database Setup"
echo "============================"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "Run: cp .env.development .env"
    exit 1
fi

# Load environment variables
source .env

echo "✅ Environment loaded"
echo "📍 Supabase URL: $SUPABASE_URL"
echo ""

echo "📋 Next Steps:"
echo ""
echo "1. Open your Supabase Dashboard:"
echo "   https://supabase.com/dashboard/project/igivbuexkliagpyakngf"
echo ""
echo "2. Go to SQL Editor (left sidebar)"
echo ""
echo "3. Click 'New Query'"
echo ""
echo "4. Copy and paste the contents of:"
echo "   backend/migrations/create_missing_tables.sql"
echo ""
echo "5. Click 'Run' to execute the migration"
echo ""
echo "📊 This will create the following tables:"
echo "   • profiles - User profiles with verification"
echo "   • favorites - Saved listings"
echo "   • purchases - Transaction history"
echo "   • offers - Bidding system"
echo "   • notifications - Push alerts"
echo ""
echo "✨ All tables include:"
echo "   • Row Level Security (RLS) policies"
echo "   • Proper indexes for performance"
echo "   • Foreign key constraints"
echo "   • Automatic timestamps"
echo ""

# Check if Python is available for verification
if command -v python3 &> /dev/null; then
    echo "🔍 Would you like to verify the database connection? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        python3 check_supabase.py
    fi
fi

echo ""
echo "✅ Setup instructions complete!"
echo "Run the migration in Supabase SQL Editor to finish setup."
