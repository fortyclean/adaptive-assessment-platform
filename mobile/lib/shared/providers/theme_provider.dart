import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';

const _themeModeKey = 'theme_mode';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _restoreThemeMode();
  }

  void setDarkMode({required bool enabled}) {
    final mode = enabled ? ThemeMode.dark : ThemeMode.light;
    state = mode;
    _saveThemeMode(mode);
  }

  Future<void> _restoreThemeMode() async {
    try {
      final box = Hive.box<dynamic>(AppConstants.sessionStateBoxName);
      final saved = box.get(_themeModeKey, defaultValue: 'light') as String;
      state = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } on Object {
      state = ThemeMode.light;
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final box = Hive.box<dynamic>(AppConstants.sessionStateBoxName);
      await box.put(_themeModeKey, mode == ThemeMode.dark ? 'dark' : 'light');
    } on Object {
      // Ignore persistence failures and keep in-memory theme state.
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
