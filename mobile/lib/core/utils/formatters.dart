import 'package:intl/intl.dart';

/// Utility functions for formatting values in the app.
/// Supports Arabic number formatting for student-facing UI.
class AppFormatters {
  AppFormatters._();

  /// Formats seconds into MM:SS display format.
  static String formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats a percentage value with one decimal place.
  static String formatPercentage(double value) =>
      '${value.toStringAsFixed(1)}%';

  /// Formats a date to a localized string.
  static String formatDate(DateTime date, {String locale = 'ar'}) {
    final formatter = DateFormat('dd/MM/yyyy', locale);
    return formatter.format(date);
  }

  /// Formats a date-time to a relative string.
  static String formatRelativeTime(DateTime dateTime, {String locale = 'ar'}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes minutes ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hours ago';
    } else {
      final days = difference.inDays;
      return '$days days ago';
    }
  }

  /// Formats a score as Arabic numerals for student-facing UI.
  static String formatArabicNumber(int number) {
    return number.toString().split('').map((d) {
      final digit = int.tryParse(d);
      return digit == null ? d : String.fromCharCode(0x0660 + digit);
    }).join();
  }

  /// Formats points with Arabic number formatting.
  static String formatPoints(int points, {bool useArabicNumerals = false}) {
    if (useArabicNumerals) {
      return formatArabicNumber(points);
    }
    return NumberFormat('#,###').format(points);
  }
}
