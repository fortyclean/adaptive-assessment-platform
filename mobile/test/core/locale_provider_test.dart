import 'package:adaptive_assessment/shared/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('locale provider defaults to Arabic and switches to English', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(localeProvider), const Locale('ar', 'SA'));

    container.read(localeProvider.notifier).setLocale(const Locale('en', 'US'));

    expect(container.read(localeProvider), const Locale('en', 'US'));
  });
}
