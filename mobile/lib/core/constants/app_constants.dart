/// Application-wide constants for the Adaptive Assessment Platform.
class AppConstants {
  AppConstants._();

  // ─── API ──────────────────────────────────────────────────────────────────
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);

  // ─── Storage Keys ─────────────────────────────────────────────────────────
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String pendingAnswersBoxName = 'pending_answers';
  static const String sessionStateBoxName = 'session_state';

  // ─── Assessment ───────────────────────────────────────────────────────────
  static const int minQuestions = 5;
  static const int maxQuestions = 50;
  static const int minTimeLimitMinutes = 5;
  static const int maxTimeLimitMinutes = 120;
  static const int timerWarningThresholdSeconds = 60;

  // ─── Pagination ───────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ─── Points ───────────────────────────────────────────────────────────────
  static const double bonusScoreThreshold = 90;
  static const int bonusPoints = 50;

  // ─── Skill Classification ─────────────────────────────────────────────────
  static const double strengthThreshold = 70;

  // ─── Notifications ────────────────────────────────────────────────────────
  static const int maxNotificationsPerUser = 50;

  // ─── UI ───────────────────────────────────────────────────────────────────
  static const double cardBorderRadius = 16;
  static const double buttonBorderRadius = 12;
  static const double inputBorderRadius = 8;
  static const double cardBorderWidth = 1;
  static const double selectedOptionBorderWidth = 2;

  // ─── Animation ────────────────────────────────────────────────────────────
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // ─── Subjects ─────────────────────────────────────────────────────────────
  static const List<String> subjects = [
    'Mathematics',
    'English',
    'Arabic',
    'Physics',
    'Chemistry',
    'Biology',
  ];
}
