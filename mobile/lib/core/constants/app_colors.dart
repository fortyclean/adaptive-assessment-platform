import 'package:flutter/material.dart';

/// Design system color palette for the Adaptive Assessment Platform.
/// Based on the Material Design 3 color system with Arabic-first RTL UI.
class AppColors {
  AppColors._();

  // ─── Primary ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF00288E);
  static const Color primaryContainer = Color(0xFF1E40AF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFDDE1FF);

  // ─── Surface ──────────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFFBF8FF);
  static const Color surfaceContainer = Color(0xFFEEEDF7);
  static const Color surfaceContainerHigh = Color(0xFFE8E7F0);
  static const Color onSurface = Color(0xFF1A1B22);
  static const Color onSurfaceVariant = Color(0xFF44464F);

  // ─── Error ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  // ─── Success ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF047857);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color onSuccess = Color(0xFFFFFFFF);

  // ─── Warning ──────────────────────────────────────────────────────────────
  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);

  // ─── Outline ──────────────────────────────────────────────────────────────
  static const Color outline = Color(0xFF757684);
  static const Color outlineVariant = Color(0xFFC4C5D5);

  // ─── MCQ Option States ────────────────────────────────────────────────────
  static const Color optionUnselectedBorder = outlineVariant;
  static const Color optionUnselectedBackground = Colors.white;
  static const Color optionSelectedBorder = primary;
  static const Color optionSelectedBackground = Color(0xFFDDE1FF);
  static const Color optionCorrectBorder = success;
  static const Color optionCorrectBackground = successContainer;
  static const Color optionIncorrectBorder = error;
  static const Color optionIncorrectBackground = errorContainer;

  // ─── Timer ────────────────────────────────────────────────────────────────
  static const Color timerNormal = onSurface;
  static const Color timerWarning = error; // <= 60 seconds remaining

  // ─── Notification ─────────────────────────────────────────────────────────
  static const Color notificationUnread = Color(0xFFEEF2FF);
  static const Color notificationUnreadIndicator = primary;

  // ─── Gamification ─────────────────────────────────────────────────────────
  static const Color pointsGold = Color(0xFFD97706);
  static const Color badgeLocked = Color(0xFF9CA3AF);
}
