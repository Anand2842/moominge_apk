#!/bin/bash

# Remove lock file if exists
rm -f .git/index.lock

# Add all ignored files
git add -f .env
git add -f .flutter-plugins-dependencies
git add -f moomingle.iml
git add -f flutter_01.log flutter_02.log flutter_03.log
git add -f .dart_tool/
git add -f .idea/
git add -f build/
git add -f android/.gradle/
git add -f android/gradlew android/gradlew.bat
git add -f android/gradle/wrapper/gradle-wrapper.jar
git add -f android/local.properties
git add -f android/moomingle_android.iml
git add -f android/app/src/main/java/
git add -f ios/Flutter/Generated.xcconfig
git add -f ios/Flutter/flutter_export_environment.sh
git add -f ios/Flutter/ephemeral/
git add -f ios/Runner/GeneratedPluginRegistrant.h
git add -f ios/Runner/GeneratedPluginRegistrant.m
git add -f linux/flutter/ephemeral/
git add -f macos/Flutter/ephemeral/
git add -f windows/flutter/ephemeral/

echo "All files added successfully!"
