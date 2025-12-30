# Moomingle - Project Structure

```
moomingle/
├── lib/                    # Flutter app source
│   ├── main.dart           # App entry point, MaterialApp config, providers
│   ├── models/             # Data models
│   │   └── cow_listing.dart    # CowListing model with fromJson factory
│   ├── screens/            # UI screens (one file per screen)
│   │   ├── main_wrapper.dart   # Bottom nav + screen switching
│   │   ├── home_screen.dart    # Swipe card browsing
│   │   ├── seller_hub_screen.dart
│   │   ├── chats_screen.dart
│   │   ├── profile_screen.dart
│   │   └── ...                 # Feature-specific screens
│   ├── services/           # Business logic & API clients
│   │   ├── api_service.dart    # Listings API (ChangeNotifier)
│   │   ├── chat_service.dart   # Chat state (ChangeNotifier)
│   │   └── breed_classifier_service.dart  # ML breed detection
│   └── widgets/            # Reusable UI components
│       └── cow_card.dart       # Swipeable listing card
├── backend/                # Python ML backend
│   ├── app.py              # Gradio interface for HF Spaces
│   ├── server.py           # Local FastAPI server
│   └── requirements.txt
├── assets/
│   └── images/             # Local image assets
├── pubspec.yaml            # Flutter dependencies
└── analysis_options.yaml   # Dart linter config
```

## Architecture Patterns

- **State Management**: Provider with ChangeNotifier classes in `services/`
- **Services extend ChangeNotifier**: `ApiService`, `ChatService` notify UI of changes
- **Screen-per-file**: Each screen in its own file under `screens/`
- **Stateful widgets**: Screens use `StatefulWidget` with `initState` for data fetching

## Conventions

- Services are registered in `main.dart` via `MultiProvider`
- Access services with `context.read<ServiceName>()` or `Consumer<ServiceName>`
- Models have `fromJson` factory constructors for API parsing
- Local assets use relative paths: `assets/images/filename.jpg`
- Network images use `CachedNetworkImage` widget
- Colors defined inline using `Color(0xFFHEXCODE)` format
