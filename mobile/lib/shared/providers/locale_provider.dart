import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';

const _localeCodeKey = 'locale_code';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ar', 'SA')) {
    _restoreLocale();
  }

  void setLocale(Locale locale) {
    state = locale;
    _saveLocale(locale);
  }

  Future<void> _restoreLocale() async {
    try {
      final box = Hive.box<dynamic>(AppConstants.sessionStateBoxName);
      final code = box.get(_localeCodeKey, defaultValue: 'ar') as String;
      state = _localeFromCode(code);
    } on Object {
      state = const Locale('ar', 'SA');
    }
  }

  Future<void> _saveLocale(Locale locale) async {
    try {
      final box = Hive.box<dynamic>(AppConstants.sessionStateBoxName);
      await box.put(_localeCodeKey, locale.languageCode);
    } on Object {
      // Keep the selected in-memory locale even if persistence fails.
    }
  }

  Locale _localeFromCode(String code) {
    if (code == 'en') return const Locale('en', 'US');
    return const Locale('ar', 'SA');
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);
