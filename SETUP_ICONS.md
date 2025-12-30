# App Icon Setup Instructions

## Step 1: Save Your Icon

Save your Moomingle logo (the M with horn and tail) as:
```
assets/images/app_icon.png
```

**Requirements:**
- Size: 1024x1024 pixels (minimum)
- Format: PNG with transparency
- Square aspect ratio

## Step 2: Generate Icons

Run these commands to generate all platform icons:

```bash
# Generate app icons for all platforms
flutter pub run flutter_launcher_icons

# Generate splash screens
flutter pub run flutter_native_splash:create
```

## Step 3: Verify

The icons will be generated for:
- ✅ Android (all densities)
- ✅ iOS (all sizes)
- ✅ Web (favicon + PWA icons)
- ✅ macOS
- ✅ Windows

## Manual Alternative

If you prefer to set icons manually:

### Android
Place icons in:
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

### iOS
Replace icons in:
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Web
Replace:
- `web/favicon.png`
- `web/icons/Icon-192.png`
- `web/icons/Icon-512.png`
