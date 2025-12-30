# Environment Configuration Guide

This guide explains how to configure Moomingle for different environments (development, staging, production).

## Quick Start

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` with your actual values:**
   ```bash
   # Required for production
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-actual-anon-key-here
   
   # Optional API endpoints
   BREED_API_URL=https://cattle-breed-api-a4q0.onrender.com
   MUZZLE_API_URL=https://cattle-breed-api-a4q0.onrender.com
   
   # Feature flags
   ENABLE_MOCK_DATA=false  # Set to false for production
   ENABLE_PAYMENTS=false
   ENABLE_PUSH_NOTIFICATIONS=false
   ENABLE_REALTIME_CHAT=false
   ```

3. **Never commit `.env` to version control!** (Already in `.gitignore`)

## Running with Environment Variables

### Development (with mock data)
```bash
flutter run --dart-define=ENV=development --dart-define=ENABLE_MOCK_DATA=true
```

### Staging
```bash
flutter run \
  --dart-define=ENV=staging \
  --dart-define=SUPABASE_URL=https://your-staging.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-staging-key \
  --dart-define=ENABLE_MOCK_DATA=false
```

### Production Build
```bash
flutter build apk \
  --dart-define=ENV=production \
  --dart-define=SUPABASE_URL=https://your-prod.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-prod-key \
  --dart-define=ENABLE_MOCK_DATA=false \
  --dart-define=ENABLE_PAYMENTS=true
```

## Configuration Files

### `lib/config/app_config.dart`
Central configuration management with environment variable support.

### `lib/config/constants.dart`
Non-sensitive constants (UI values, breed lists, etc.)

## Feature Flags

| Flag | Default | Description |
|------|---------|-------------|
| `ENABLE_MOCK_DATA` | `true` | Enable fallback mock data when APIs fail |
| `ENABLE_PAYMENTS` | `false` | Enable payment features (boost, premium) |
| `ENABLE_PUSH_NOTIFICATIONS` | `false` | Enable push notification system |
| `ENABLE_REALTIME_CHAT` | `false` | Enable real-time chat via Supabase |

## Security Best Practices

1. **Never commit secrets** - Use environment variables
2. **Rotate keys regularly** - Especially after team changes
3. **Use different keys per environment** - Dev, staging, prod should be separate
4. **Restrict API keys** - Use Supabase RLS and API key restrictions

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: Build APK
  run: |
    flutter build apk \
      --dart-define=ENV=production \
      --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
      --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
```

### Store secrets in your CI/CD platform:
- GitHub: Settings → Secrets and variables → Actions
- GitLab: Settings → CI/CD → Variables
- Bitbucket: Repository settings → Pipelines → Repository variables

## Troubleshooting

### "Supabase not configured" warning
- Ensure `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set
- Check that values don't have extra spaces or quotes
- Verify the URL format: `https://xxx.supabase.co`

### Mock data still showing in production
- Set `ENABLE_MOCK_DATA=false` in build command
- Verify with: `AppConfig.enableMockData` should return `false`

### API calls failing
- Check network connectivity
- Verify API URLs are correct
- Check Supabase dashboard for service status
- Review API logs for authentication errors
