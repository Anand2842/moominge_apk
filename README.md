# 🐄 Moomingle

A "Tinder-style" mobile marketplace for buying and selling cattle and buffalo in India. Swipe through livestock listings, match with sellers, and chat to negotiate purchases.

## ✨ Features

- **Swipe-based browsing** - Card-based UI for discovering cattle/buffalo listings
- **AI breed classification** - ML-powered breed identification from photos
- **Seller hub** - Dashboard for managing listings and viewing performance
- **In-app chat** - Messaging between buyers and sellers after matching
- **Verification system** - Verified badges for authenticated livestock listings
- **Muzzle biometrics** - Unique identification using muzzle prints

## 🚀 Quick Start

```bash
# Clone the repository
git clone <repo-url>
cd moomingle

# Set up environment (interactive)
./scripts/setup_env.sh

# Or manually
cp .env.example .env
# Edit .env with your values

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | Quick reference for common tasks |
| [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) | Configuration and environment setup |
| [CLEANUP_STATUS.md](CLEANUP_STATUS.md) | Mock data cleanup status |
| [CONFIGURATION_MIGRATION_SUMMARY.md](CONFIGURATION_MIGRATION_SUMMARY.md) | Configuration migration details |
| [DETAILED_PROJECT_REPORT.md](DETAILED_PROJECT_REPORT.md) | Complete project analysis |
| [PRODUCTION_READINESS_CHECKLIST.md](PRODUCTION_READINESS_CHECKLIST.md) | Pre-launch checklist |

## 🏗️ Tech Stack

**Frontend:**
- Flutter 3.x with Dart
- Provider for state management
- Supabase for backend & auth
- Cached Network Image for image handling

**Backend:**
- Supabase (Postgres, Auth, Storage)
- Python ML API (Render/HuggingFace)
- ONNX Runtime for breed classification

**Platforms:** iOS, Android, Web, macOS, Linux, Windows

## 📁 Project Structure

```
lib/
├── config/              # Configuration & constants
├── models/              # Data models
├── screens/             # UI screens
├── services/            # Business logic (ChangeNotifier)
└── widgets/             # Reusable components

backend/
├── api.py               # FastAPI server
└── requirements.txt     # Python dependencies
```

## ⚙️ Configuration

### Environment Variables

Create a `.env` file (copy from `.env.development`):

```bash
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
BREED_API_URL=https://cattle-breed-api-a4q0.onrender.com
ENABLE_MOCK_DATA=true
```

### Feature Flags

- `ENABLE_MOCK_DATA` - Use fallback data when APIs fail (default: true)
- `ENABLE_PAYMENTS` - Enable payment features (default: false)
- `ENABLE_PUSH_NOTIFICATIONS` - Enable push notifications (default: false)
- `ENABLE_REALTIME_CHAT` - Enable real-time chat (default: false)

See [CONFIG.md](CONFIG.md) for detailed configuration instructions.

## 🔨 Development

```bash
# Run on specific device
flutter run -d chrome    # Web
flutter run -d macos     # macOS
flutter run -d ios       # iOS simulator

# Run tests
flutter test

# Analyze code
flutter analyze

# Check dependencies
flutter pub outdated
```

## 📦 Building for Production

### Android
```bash
flutter build apk \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=ENABLE_MOCK_DATA=false
```

### iOS
```bash
flutter build ios \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=ENABLE_MOCK_DATA=false
```

### Web
```bash
flutter build web \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=ENABLE_MOCK_DATA=false
```

## 🎨 Design System

- **Primary Color:** `#8B5A2B` (Brown)
- **Background:** `#F5E0C3` (Cream)
- **Secondary:** `#E8B888` (Tan)
- **Card Border Radius:** 32px
- **Button Border Radius:** 20px

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 🔐 Security

- ✅ No hardcoded credentials (moved to environment variables)
- ✅ Secure token storage with flutter_secure_storage
- ✅ HTTPS for all API calls
- ✅ Supabase Row Level Security (RLS) policies
- ⚠️ Enable code obfuscation for production builds

See [PRODUCTION_READINESS_CHECKLIST.md](PRODUCTION_READINESS_CHECKLIST.md) for complete security checklist.

## 📱 Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ | API 21+ |
| iOS | ✅ | iOS 12+ |
| Web | ✅ | Modern browsers |
| macOS | ✅ | macOS 10.14+ |
| Linux | ✅ | |
| Windows | ✅ | |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is proprietary. All rights reserved.

## 🆘 Support

- Check [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for common tasks
- Review [DETAILED_PROJECT_REPORT.md](DETAILED_PROJECT_REPORT.md) for architecture
- Check [CONFIG.md](CONFIG.md) for configuration issues
- Contact: support@moomingle.com

## 🎯 Roadmap

- [ ] Payment integration (Razorpay/UPI)
- [ ] Push notifications (Firebase Cloud Messaging)
- [ ] Real-time chat (Supabase Realtime)
- [ ] Advanced search filters
- [ ] Seller verification system
- [ ] Multi-language support (Hindi, English)

## 📊 Project Status

- **Version:** 1.0.2
- **Status:** Development
- **Last Updated:** December 2024

---

Made with ❤️ for Indian cattle and buffalo traders
