/// App configuration for different environments.
/// Requirements: 20.2
///
/// Build with:
///   Development:  flutter run --dart-define=ENV=development
///   Production:   flutter build apk --dart-define=ENV=production --dart-define=API_URL=https://api.example.com/api/v1
class AppConfig {
  AppConfig._();

  static const String _env =
      String.fromEnvironment('ENV', defaultValue: 'development');

  static const String _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  static bool get isProduction => _env == 'production';
  static bool get isDevelopment => _env == 'development';

  static String get apiBaseUrl => _apiUrl;

  /// Android build commands:
  ///   Debug APK:    flutter build apk --debug
  ///   Release APK:  flutter build apk --release --dart-define=ENV=production --dart-define=API_URL=https://api.example.com/api/v1
  ///   Release AAB:  flutter build appbundle --release --dart-define=ENV=production --dart-define=API_URL=https://api.example.com/api/v1
  ///
  /// iOS build commands:
  ///   Debug:        flutter build ios --debug
  ///   Release:      flutter build ios --release --dart-define=ENV=production --dart-define=API_URL=https://api.example.com/api/v1
  ///
  /// Upload to stores:
  ///   Android: Upload AAB to Google Play Console
  ///   iOS:     Use Xcode Organizer or fastlane to upload to App Store Connect
}
