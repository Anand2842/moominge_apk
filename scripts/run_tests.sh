#!/bin/bash

# Moomingle Test Runner
# Runs all tests with coverage reporting

set -e

echo "🧪 Running Moomingle Tests..."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Run unit tests
echo -e "${YELLOW}Running unit tests...${NC}"
flutter test test/models/ test/services/ --coverage

# Run widget tests
echo -e "${YELLOW}Running widget tests...${NC}"
flutter test test/widgets/ --coverage

# Run integration tests
echo -e "${YELLOW}Running integration tests...${NC}"
flutter test test/integration/ --coverage

# Generate coverage report
if command -v lcov &> /dev/null; then
    echo -e "${YELLOW}Generating coverage report...${NC}"
    
    # Remove unwanted files from coverage
    lcov --remove coverage/lcov.info \
        'lib/generated/*' \
        'lib/*/*.g.dart' \
        'lib/main.dart' \
        -o coverage/lcov.info
    
    # Generate HTML report
    genhtml coverage/lcov.info -o coverage/html
    
    echo -e "${GREEN}✅ Coverage report generated at coverage/html/index.html${NC}"
else
    echo -e "${YELLOW}⚠️  lcov not installed. Skipping coverage report generation.${NC}"
    echo "Install with: brew install lcov (macOS) or apt-get install lcov (Linux)"
fi

# Run analyzer
echo -e "${YELLOW}Running Flutter analyzer...${NC}"
flutter analyze

# Check formatting
echo -e "${YELLOW}Checking code formatting...${NC}"
dart format --set-exit-if-changed lib/ test/

echo ""
echo -e "${GREEN}✅ All tests completed successfully!${NC}"
echo ""
echo "Test Summary:"
echo "  - Unit tests: ✓"
echo "  - Widget tests: ✓"
echo "  - Integration tests: ✓"
echo "  - Code analysis: ✓"
echo "  - Code formatting: ✓"
