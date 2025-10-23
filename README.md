# Quiet Camera 📷🔇

A premium silent camera application that provides the native iPhone camera experience without the shutter sound.

## 🎯 Features

- **Complete Silence**: Zero shutter sound during photo and video capture
- **Native Quality**: Maintains original camera quality (HEIF, ProRAW support)
- **iPhone-Style UI**: Familiar and intuitive interface matching iOS Camera app
- **Advanced Features**:
  - Multi-lens support (0.5x, 1x, 2x zoom)
  - Flash control (Auto/On/Off)
  - Portrait mode with depth effects
  - Night mode
  - 4K video recording at 60fps
  - Live Photos
  - Burst mode

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                  # Shared utilities and constants
│   ├── constants/        # App-wide constants
│   ├── theme/           # Theme and colors
│   ├── utils/           # Helper functions
│   └── error/           # Error handling
├── features/            # Feature modules
│   ├── camera/          # Camera capture feature
│   │   ├── presentation/  # UI layer (pages, widgets, providers)
│   │   ├── domain/        # Business logic (entities, repositories)
│   │   └── data/          # Data layer (datasources, models)
│   ├── gallery/         # Photo gallery feature
│   └── settings/        # App settings feature
└── platform/            # Native platform integration
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.24 or higher
- Dart 3.5 or higher
- Xcode 15+ (for iOS)
- Android Studio (for Android)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/leejaeseong11/quiet-camera.git
cd quiet-camera
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

## 📱 Platform-Specific Setup

### iOS

1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing & capabilities
3. Add camera and photo library permissions in `Info.plist`

### Android

1. Open `android/` folder in Android Studio
2. Configure signing keys
3. Permissions are auto-configured in `AndroidManifest.xml`

## 🧪 Testing

Run tests:
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

## 📦 Build

### iOS
```bash
flutter build ios --release
```

### Android
```bash
flutter build appbundle --release
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.24+
- **State Management**: Riverpod 2.4+
- **Navigation**: go_router
- **Camera**: camera, AVFoundation (iOS), Camera2 API (Android)
- **Storage**: shared_preferences, path_provider

## 🔐 Privacy

- All photos and videos are stored locally on your device
- No data is sent to external servers
- No analytics or tracking
- Camera permissions are only used for capturing media

## 📄 License

Proprietary - All rights reserved

## 👥 Team

- **Developer**: Lee Jaeseong (@leejaeseong11)

## 🗺️ Roadmap

- [x] Project setup and architecture
- [ ] Silent photo capture (iOS/Android)
- [ ] Basic camera UI
- [ ] Zoom and flash controls
- [ ] Video recording
- [ ] Gallery viewer
- [ ] Advanced camera modes
- [ ] Settings screen
- [ ] App Store release
- [ ] Play Store release

---

**Made with ❤️ for silent photography enthusiasts**
