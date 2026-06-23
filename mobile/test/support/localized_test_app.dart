import 'package:adaptive_assessment/core/theme/app_theme.dart';
import 'package:adaptive_assessment/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Standard widget-test host for localized, RTL-first application screens.
Widget pumpLocalizedApp(
  Widget home, {
  List<Override> overrides = const [],
  ThemeMode themeMode = ThemeMode.light,
}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: home,
      ),
    );
