# Moomingle - Quick Reference Card

## 🚀 Quick Start

```bash
# First time setup
./scripts/setup_env.sh
flutter pub get
flutter run

# Or manually
cp .env.example .env
# Edit .env with your values
flutter run
```

## 🔧 Common Commands

### Development
```bash
# Run with mock data (default)
flutter run

# Run without mock data
flutter run --dart-define=ENABLE_MOCK_DATA=false

# Run on specific device
flutter run -d chrome    # Web
flutter run -d macos     # macOS
flutter run -d ios       # iOS
```

### Production Build
```bash
# Android
flutter build apk \
  --dart-define=ENV=production \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=ENABLE_MOCK_DATA=false

# iOS
flutter build ios \
  --dart-define=ENV=production \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=ENABLE_MOCK_DATA=false
```

### Testing & Analysis
```bash
flutter analyze              # Check for issues
flutter test                 # Run tests
flutter test --coverage      # With coverage
```

## 📁 Key Files

| File | Purpose |
|------|---------|
| `lib/config/app_config.dart` | Environment configuration |
| `lib/config/constants.dart` | App constants |
| `.env` | Local environment variables (never commit!) |
| `.env.example` | Template for .env |

## 🎛️ Feature Flags

| Flag | Default | Purpose |
|------|---------|---------|
| `ENABLE_MOCK_DATA` | `true` | Enable fallback mock data |
| `ENABLE_PAYMENTS` | `false` | Enable payment features |
| `ENABLE_PUSH_NOTIFICATIONS` | `false` | Enable notifications |
| `ENABLE_REALTIME_CHAT` | `false` | Enable real-time chat |

## 🔐 Environment Variables

### Required for Production
```bash
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=your-key-here
```

### Optional
```bash
BREED_API_URL=https://cattle-breed-api-a4q0.onrender.com
MUZZLE_API_URL=https://cattle-breed-api-a4q0.onrender.com
```

## 🏗️ Project Structure

```
lib/
├── config/          # Configuration files
├── models/          # Data models
├── screens/         # UI screens
├── services/        # Business logic
└── widgets/         # Reusable components
```

## 🐛 Troubleshooting

### "Supabase not configured"
```bash
# Set environment variables
flutter run \
  --dart-define=SUPABASE_URL=xxx \
  --dart-define=SUPABASE_ANON_KEY=xxx
```

### Mock data in production
```bash
# Disable mock data
flutter build apk --dart-define=ENABLE_MOCK_DATA=false
```

### Build fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk
```

## 📚 Documentation

- `ENVIRONMENT_SETUP.md` - Full setup guide
- `CLEANUP_STATUS.md` - What was cleaned up
- `CONFIGURATION_MIGRATION_SUMMARY.md` - Migration details
- `PRODUCTION_READINESS_CHECKLIST.md` - Production checklist

## 🔗 Important Links

- Supabase Dashboard: https://supabase.com/dashboard
- Breed API: https://cattle-breed-api-a4q0.onrender.com
- Flutter Docs: https://docs.flutter.dev

## ⚠️ Never Commit

- `.env` file
- API keys or tokens
- Production credentials
- Personal data

## 💡 Tips

1. **Use mock data for development** - Set `ENABLE_MOCK_DATA=true`
2. **Test without backend** - Mock data allows offline development
3. **Check logs** - Look for "⚠️ Loading mock data" messages
4. **Verify builds** - Always test production builds before release
5. **Keep secrets safe** - Use environment variables, never hardcode

## 🆘 Need Help?

1. Check documentation files listed above
2. Run `flutter doctor` to check setup
3. Review error messages carefully
4. Check Supabase dashboard for API issues

## 📝 Quick Checklist

Before committing:
- [ ] No secrets in code
- [ ] `.env` not committed
- [ ] Code analyzed (`flutter analyze`)
- [ ] Tests pass (`flutter test`)

Before production:
- [ ] Mock data disabled
- [ ] Production credentials set
- [ ] Build tested thoroughly
- [ ] Feature flags configured
