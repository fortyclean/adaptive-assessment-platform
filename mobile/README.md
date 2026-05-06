# Adaptive Assessment Platform — Flutter Mobile App

## Prerequisites
- Flutter SDK 3.19+
- Dart 3.3+
- Android Studio / Xcode

## Setup Instructions

1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Navigate to this directory: `cd mobile`
3. Install dependencies:

```bash
flutter pub get
```

4. Configure API base URL in `lib/core/constants/app_constants.dart`
5. Run the app:

```bash
flutter run
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  dio: ^5.4.3+1
  hive_flutter: ^1.1.0
  go_router: ^14.2.0
  flutter_secure_storage: ^9.2.2
  intl: ^0.19.0
  google_fonts: ^6.2.1
  connectivity_plus: ^6.0.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.11
  hive_generator: ^2.0.1
```

## Project Structure

```
lib/
├── core/
│   ├── constants/     # App constants, colors, text styles
│   ├── router/        # GoRouter navigation setup
│   ├── theme/         # App theme (RTL, Almarai/Lexend fonts)
│   └── utils/         # Formatters, validators
├── features/
│   ├── auth/          # Login, forgot password, change password
│   ├── assessment/    # Exam screen, start screen, results
│   ├── question_bank/ # Question bank management
│   ├── reports/       # Teacher and admin reports
│   └── notifications/ # In-app notifications
└── shared/
    ├── providers/     # Riverpod global providers
    └── widgets/       # Reusable UI components
```

## Design System

- **Primary Color**: `#00288E` (Academy Blue)
- **Error Color**: `#BA1A1A`
- **Success Color**: `#047857`
- **Font (Arabic)**: Almarai
- **Font (Latin)**: Lexend
- **Direction**: RTL (Right-to-Left) by default

## Running Tests

```bash
flutter test
```

## Building for Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```
