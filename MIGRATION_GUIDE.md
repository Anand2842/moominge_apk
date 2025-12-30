# Migration Guide: Configuration Updates

This guide helps you migrate to the new configuration system introduced in the latest update.

## What Changed?

### Before (Old System)
- Hardcoded Supabase credentials in `supabase_service.dart`
- Hardcoded API URLs in service files
- Hardcoded support email, version, etc. scattered across screens
- No centralized configuration management

### After (New System)
- All configuration in `lib/config/app_config.dart`
- Environment variables for sensitive data
- Feature flags for toggling functionality
- Centralized constants in `lib/config/constants.dart`

## Migration Steps

### Step 1: Set Up Environment File

```bash
# Copy the development environment template
cp .env.development .env
```

The `.env` file is gitignored and contains your local development credentials.

### Step 2: Verify Configuration

Check that `lib/config/app_config.dart` exists and contains:
- API endpoints
- Feature flags
- App metadata
- Contact information

### Step 3: Update Your Code (If You Have Custom Changes)

If you've made custom modifications to services, update them to use `AppConfig`:

**Old:**
```dart
static const String apiUrl = 'https://my-api.com';
```

**New:**
```dart
import '../config/app_config.dart';

static String get apiUrl => AppConfig.breedApiUrl;
```

### Step 4: Test Your Setup

```bash
# Run the app in development mode
flutter run

# Verify mock data is working (if enabled)
# Check that API calls work with your credentials
```

### Step 5: Production Builds

For production, pass environment variables at build time:

```bash
flutter build apk \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_production_key \
  --dart-define=ENABLE_MOCK_DATA=false
```

## Feature Flags

Control app behavior with feature flags:

| Flag | Purpose | Default |
|------|---------|---------|
| `ENABLE_MOCK_DATA` | Use fallback data when APIs fail | `true` |
| `ENABLE_PAYMENTS` | Enable payment features | `false` |
| `ENABLE_PUSH_NOTIFICATIONS` | Enable push notifications | `false` |
| `ENABLE_REALTIME_CHAT` | Enable real-time chat | `false` |

### Example: Disable Mock Data

```bash
flutter run --dart-define=ENABLE_MOCK_DATA=false
```

This will cause the app to throw errors instead of using mock data, helping you catch configuration issues.

## Troubleshooting

### Issue: "Supabase not configured" error

**Solution:** Make sure you have a `.env` file with valid credentials:
```bash
cp .env.development .env
# Edit .env with your credentials
```

### Issue: App shows mock data in production

**Solution:** Build with `ENABLE_MOCK_DATA=false`:
```bash
flutter build apk --dart-define=ENABLE_MOCK_DATA=false
```

### Issue: "No such file" error for AppConfig

**Solution:** Make sure you've pulled the latest code:
```bash
git pull origin main
flutter pub get
```

### Issue: Import errors in screens

**Solution:** Some screens now import `AppConfig`. If you see import errors:
```dart
import 'package:moomingle/config/app_config.dart';
```

## Rollback (If Needed)

If you need to rollback to the old system:

```bash
git checkout <previous-commit-hash>
flutter pub get
flutter run
```

However, we recommend migrating forward as the new system is more secure and maintainable.

## Benefits of New System

1. **Security**: No credentials in source code
2. **Flexibility**: Easy to switch between environments
3. **Maintainability**: All config in one place
4. **Feature Control**: Toggle features without code changes
5. **Production Ready**: Proper separation of dev/prod config

## Need Help?

- Check `CONFIG.md` for detailed configuration documentation
- Check `CLEANUP_SUMMARY.md` for what changed
- Contact the team if you have issues

## Checklist

- [ ] Copied `.env.development` to `.env`
- [ ] Verified app runs in development mode
- [ ] Tested that mock data works (if enabled)
- [ ] Tested production build command
- [ ] Updated any custom code to use `AppConfig`
- [ ] Read `CONFIG.md` for full documentation
