import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Material 3 theme configuration for the Adaptive Assessment Platform.
/// Implements RTL-first Arabic design with the defined color system.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.primaryContainer,
          onSecondary: AppColors.onPrimary,
          secondaryContainer: AppColors.surfaceContainer,
          onSecondaryContainer: AppColors.onSurface,
          tertiary: AppColors.success,
          onTertiary: AppColors.onSuccess,
          tertiaryContainer: AppColors.successContainer,
          onTertiaryContainer: AppColors.success,
          error: AppColors.error,
          onError: AppColors.onError,
          errorContainer: AppColors.errorContainer,
          onErrorContainer: AppColors.onErrorContainer,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          surfaceContainerHighest: AppColors.surfaceContainerHigh,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
        ),
        fontFamily: 'Almarai',
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          labelLarge: AppTextStyles.labelLarge,
          labelMedium: AppTextStyles.labelMedium,
          labelSmall: AppTextStyles.labelSmall,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: true,
          titleTextStyle: AppTextStyles.titleLarge,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: AppColors.outlineVariant,
              width: 1,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTextStyles.labelLarge.copyWith(fontSize: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTextStyles.labelLarge.copyWith(fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
        ),
        scaffoldBackgroundColor: AppColors.surface,
        dividerTheme: const DividerThemeData(
          color: AppColors.outlineVariant,
          thickness: 1,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.surfaceContainer,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceContainer,
          labelStyle: AppTextStyles.labelMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

  static ThemeData get darkTheme => lightTheme.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: lightTheme.colorScheme.copyWith(
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A),
          onSurface: const Color(0xFFE5E7EB),
          surfaceContainerHighest: const Color(0xFF1E293B),
          outline: const Color(0xFF475569),
          outlineVariant: const Color(0xFF334155),
        ),
        cardTheme: lightTheme.cardTheme.copyWith(
          color: const Color(0xFF111827),
        ),
        appBarTheme: lightTheme.appBarTheme.copyWith(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: const Color(0xFFE5E7EB),
        ),
        inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
          fillColor: const Color(0xFF1F2937),
        ),
      );
}
