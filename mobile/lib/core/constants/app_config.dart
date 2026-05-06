/// App configuration for different environments.
/// Requirements: 20.2
class AppConfig {
  AppConfig._();

  static const String _env =
      String.fromEnvironment('ENV', defaultValue: 'development');

  static const String _apiUrl = String.fromEnvironment(
    'API_URL',
    // In development, use 10.0.2.2 for Android emulator (maps to host localhost)
    // For real device on same WiFi, this gets overridden by --dart-define=API_URL=...
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  static bool get isProduction => _env == 'production';
  static bool get isDevelopment => _env == 'development';

  static String get apiBaseUrl => _apiUrl;
}
