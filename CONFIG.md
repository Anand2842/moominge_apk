# Configuration Guide

## Environment Setup

Moomingle uses environment variables for configuration. This keeps sensitive data out of the codebase.

### Development Setup

1. Copy the development environment file:
```bash
cp .env.development .env
```

2. The `.env` file is gitignored and won't be committed.

### Production Build

For production builds, pass environment variables at build time:

```bash
# Android
flutter build apk \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=ENABLE_MOCK_DATA=false

# iOS
flutter build ios \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=ENABLE_MOCK_DATA=false

# Web
flutter build web \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=ENABLE_MOCK_DATA=false
```

## Configuration Files

### `lib/config/app_config.dart`
Central configuration file containing:
- API endpoints
- Feature flags
- App metadata (version, name)
- Contact information
- Timeout settings

### `lib/config/constants.dart`
UI and business logic constants:
- Placeholder image URLs
- UI dimensions and animations
- Validation limits
- Cache settings

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SUPABASE_URL` | Yes | - | Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | - | Supabase anonymous key |
| `BREED_API_URL` | No | Render API | Breed classification API endpoint |
| `MUZZLE_API_URL` | No | Render API | Muzzle verification API endpoint |
| `ENABLE_MOCK_DATA` | No | true | Enable fallback mock data |
| `ENABLE_PAYMENTS` | No | false | Enable payment features |
| `ENABLE_PUSH_NOTIFICATIONS` | No | false | Enable push notifications |
| `ENABLE_REALTIME_CHAT` | No | false | Enable real-time chat |

## Feature Flags

Feature flags allow you to enable/disable features without code changes:

- **ENABLE_MOCK_DATA**: When true, services fall back to mock data if APIs fail
- **ENABLE_PAYMENTS**: Payment integration (not yet implemented)
- **ENABLE_PUSH_NOTIFICATIONS**: Push notification support (not yet implemented)
- **ENABLE_REALTIME_CHAT**: Real-time chat via Supabase Realtime (not yet implemented)

## Security Best Practices

1. **Never commit `.env` files** - They're in `.gitignore`
2. **Use different credentials for dev/staging/prod**
3. **Rotate keys regularly**
4. **Use Supabase RLS policies** to protect data
5. **For CI/CD**, set environment variables in your pipeline

## Updating Configuration

### To add a new config value:

1. Add it to `AppConfig` in `lib/config/app_config.dart`:
```dart
static const String myNewConfig = String.fromEnvironment(
  'MY_NEW_CONFIG',
  defaultValue: 'default_value',
);
```

2. Add it to `.env.example` and `.env.development`

3. Document it in this file

4. Update any screens/services that need it

## Mock Data

Mock data is controlled by `AppConfig.enableMockData`. When enabled:
- Services fall back to hardcoded data if APIs fail
- Useful for development and offline testing
- Should be disabled in production

To disable mock data:
```bash
flutter run --dart-define=ENABLE_MOCK_DATA=false
```
