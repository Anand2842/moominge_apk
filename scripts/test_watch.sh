#!/bin/bash

# Moomingle Test Watcher
# Watches for file changes and runs tests automatically

echo "👀 Watching for changes and running tests..."
echo "Press Ctrl+C to stop"
echo ""

# Run tests on file changes
flutter test --watch
