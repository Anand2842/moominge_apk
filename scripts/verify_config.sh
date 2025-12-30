#!/bin/bash
# Configuration verification script for Moomingle

set -e

echo "🔍 Moomingle Configuration Verification"
echo "========================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to print status
print_status() {
    if [ "$1" = "PASS" ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((PASSED++))
    elif [ "$1" = "FAIL" ]; then
        echo -e "${RED}✗${NC} $2"
        ((FAILED++))
    elif [ "$1" = "WARN" ]; then
        echo -e "${YELLOW}⚠${NC} $2"
        ((WARNINGS++))
    fi
}

echo "1. Checking Files"
echo "-----------------"

# Check if .env exists
if [ -f ".env" ]; then
    print_status "PASS" ".env file exists"
else
    print_status "FAIL" ".env file missing (run: cp .env.example .env)"
fi

# Check if .env.example exists
if [ -f ".env.example" ]; then
    print_status "PASS" ".env.example exists"
else
    print_status "FAIL" ".env.example missing"
fi

# Check if config files exist
if [ -f "lib/config/app_config.dart" ]; then
    print_status "PASS" "app_config.dart exists"
else
    print_status "FAIL" "app_config.dart missing"
fi

if [ -f "lib/config/constants.dart" ]; then
    print_status "PASS" "constants.dart exists"
else
    print_status "FAIL" "constants.dart missing"
fi

echo ""
echo "2. Checking .gitignore"
echo "----------------------"

# Check if .env is in .gitignore
if grep -q "^\.env$" .gitignore 2>/dev/null; then
    print_status "PASS" ".env is in .gitignore"
else
    print_status "FAIL" ".env not in .gitignore (SECURITY RISK!)"
fi

echo ""
echo "3. Checking for Hardcoded Secrets"
echo "----------------------------------"

# Check for JWT tokens (Supabase keys start with eyJ)
if grep -r "eyJ" lib/ 2>/dev/null | grep -v "app_config.dart" | grep -v ".dart_tool" > /dev/null; then
    print_status "FAIL" "Found potential hardcoded JWT tokens in code"
    echo "   Run: grep -r 'eyJ' lib/ to find them"
else
    print_status "PASS" "No hardcoded JWT tokens found"
fi

# Check for hardcoded Supabase URLs
SUPABASE_COUNT=$(grep -r "supabase.co" lib/ 2>/dev/null | grep -v "app_config.dart" | grep -v ".dart_tool" | wc -l)
if [ "$SUPABASE_COUNT" -gt 0 ]; then
    print_status "WARN" "Found $SUPABASE_COUNT hardcoded Supabase URLs (should be in AppConfig)"
else
    print_status "PASS" "No hardcoded Supabase URLs outside config"
fi

echo ""
echo "4. Checking Environment Variables"
echo "----------------------------------"

if [ -f ".env" ]; then
    # Check if SUPABASE_URL is set
    if grep -q "^SUPABASE_URL=" .env && ! grep -q "^SUPABASE_URL=https://your-project.supabase.co" .env; then
        print_status "PASS" "SUPABASE_URL is configured"
    else
        print_status "WARN" "SUPABASE_URL not configured (using default)"
    fi
    
    # Check if SUPABASE_ANON_KEY is set
    if grep -q "^SUPABASE_ANON_KEY=" .env && ! grep -q "^SUPABASE_ANON_KEY=your-anon-key-here" .env; then
        print_status "PASS" "SUPABASE_ANON_KEY is configured"
    else
        print_status "WARN" "SUPABASE_ANON_KEY not configured (using default)"
    fi
    
    # Check ENV setting
    if grep -q "^ENV=" .env; then
        ENV_VALUE=$(grep "^ENV=" .env | cut -d'=' -f2)
        print_status "PASS" "ENV is set to: $ENV_VALUE"
    else
        print_status "WARN" "ENV not set (will use default: development)"
    fi
fi

echo ""
echo "5. Checking Feature Flags"
echo "-------------------------"

if [ -f ".env" ]; then
    # Check ENABLE_MOCK_DATA
    if grep -q "^ENABLE_MOCK_DATA=true" .env; then
        print_status "PASS" "Mock data enabled (good for development)"
    elif grep -q "^ENABLE_MOCK_DATA=false" .env; then
        print_status "PASS" "Mock data disabled (production mode)"
    else
        print_status "WARN" "ENABLE_MOCK_DATA not set (will use default: true)"
    fi
fi

echo ""
echo "6. Checking Flutter Setup"
echo "-------------------------"

# Check if Flutter is installed
if command -v flutter &> /dev/null; then
    print_status "PASS" "Flutter is installed"
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo "   $FLUTTER_VERSION"
else
    print_status "FAIL" "Flutter not found in PATH"
fi

# Check if pubspec.yaml exists
if [ -f "pubspec.yaml" ]; then
    print_status "PASS" "pubspec.yaml exists"
else
    print_status "FAIL" "pubspec.yaml missing"
fi

echo ""
echo "7. Checking Documentation"
echo "-------------------------"

DOCS=("ENVIRONMENT_SETUP.md" "CLEANUP_STATUS.md" "QUICK_REFERENCE.md" "CONFIGURATION_MIGRATION_SUMMARY.md")
for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        print_status "PASS" "$doc exists"
    else
        print_status "WARN" "$doc missing"
    fi
done

echo ""
echo "========================================"
echo "Summary"
echo "========================================"
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Failed:${NC} $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Configuration looks good!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review any warnings above"
    echo "2. Run: flutter pub get"
    echo "3. Run: flutter run"
    exit 0
else
    echo -e "${RED}✗ Configuration has issues that need to be fixed${NC}"
    echo ""
    echo "Please address the failed checks above."
    exit 1
fi
