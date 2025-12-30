#!/bin/bash
# Environment setup script for Moomingle

set -e

echo "🐄 Moomingle Environment Setup"
echo "================================"
echo ""

# Check if .env already exists
if [ -f ".env" ]; then
    echo "⚠️  .env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing .env file."
        exit 0
    fi
fi

# Copy example file
cp .env.example .env
echo "✅ Created .env from .env.example"
echo ""

# Prompt for environment
echo "Select environment:"
echo "1) Development (with mock data)"
echo "2) Staging"
echo "3) Production"
read -p "Enter choice (1-3): " env_choice

case $env_choice in
    1)
        ENV="development"
        ENABLE_MOCK="true"
        ;;
    2)
        ENV="staging"
        ENABLE_MOCK="false"
        ;;
    3)
        ENV="production"
        ENABLE_MOCK="false"
        ;;
    *)
        echo "Invalid choice. Defaulting to development."
        ENV="development"
        ENABLE_MOCK="true"
        ;;
esac

# Update .env file
sed -i.bak "s/ENV=development/ENV=$ENV/" .env
sed -i.bak "s/ENABLE_MOCK_DATA=true/ENABLE_MOCK_DATA=$ENABLE_MOCK/" .env
rm .env.bak

echo ""
echo "✅ Environment set to: $ENV"
echo ""

# Prompt for Supabase credentials if not development
if [ "$ENV" != "development" ]; then
    echo "📝 Supabase Configuration"
    echo "-------------------------"
    read -p "Enter Supabase URL: " supabase_url
    read -p "Enter Supabase Anon Key: " supabase_key
    
    sed -i.bak "s|SUPABASE_URL=.*|SUPABASE_URL=$supabase_url|" .env
    sed -i.bak "s|SUPABASE_ANON_KEY=.*|SUPABASE_ANON_KEY=$supabase_key|" .env
    rm .env.bak
    
    echo "✅ Supabase credentials configured"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review and edit .env if needed"
echo "2. Run: flutter pub get"
echo "3. Run: flutter run"
echo ""
echo "⚠️  Remember: Never commit .env to version control!"
