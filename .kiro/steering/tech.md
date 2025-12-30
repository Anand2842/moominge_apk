# Moomingle - Tech Stack

## Frontend (Flutter)

- **Framework**: Flutter 3.x with Dart SDK >=3.0.0 <4.0.0
- **State Management**: Provider (`provider: ^6.0.5`)
- **Networking**: `http: ^1.1.0`
- **Image Handling**: `cached_network_image: ^3.3.0`, `image_picker: ^1.0.4`
- **Formatting**: `intl: ^0.18.1` for currency/date formatting
- **Linting**: `flutter_lints: ^3.0.0`

## Backend (Python)

- **ML Inference**: ONNX Runtime with Hugging Face model (`vishnuamar/cattle-breed-classifier`)
- **API Framework**: Gradio (for HF Spaces), FastAPI (local server option)
- **Image Processing**: PIL, torchvision transforms

## Supported Platforms

iOS, Android, Web, macOS, Linux, Windows (Flutter multi-platform)

## Common Commands

```bash
# Run the app (debug mode)
flutter run

# Run on specific device
flutter run -d chrome    # Web
flutter run -d macos     # macOS
flutter run -d ios       # iOS simulator

# Build release
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web

# Analyze code
flutter analyze

# Run tests
flutter test

# Get dependencies
flutter pub get

# Backend (local ML server)
cd backend && python server.py
```

## Key Dependencies

| Package | Purpose |
|---------|---------|
| provider | State management via ChangeNotifier |
| http | REST API calls |
| cached_network_image | Image caching with placeholders |
| image_picker | Camera/gallery access for breed scanner |
| intl | Number/currency formatting (Indian Rupees) |
