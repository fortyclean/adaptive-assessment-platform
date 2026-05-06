import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography system for the Adaptive Assessment Platform.
/// Uses Almarai for Arabic text and Lexend for Latin text.
/// All sizes follow the design system specification.
class AppTextStyles {
  AppTextStyles._();

  static const String _arabicFont = 'Almarai';

  // ─── Display ──────────────────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _arabicFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    height: 1.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _arabicFont,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    height: 1.3,
  );

  // ─── Title ────────────────────────────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _arabicFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _arabicFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.4,
  );

  // ─── Body ─────────────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _arabicFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _arabicFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.5,
  );

  // ─── Label ────────────────────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _arabicFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _arabicFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _arabicFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
    height: 1.4,
  );
}
