import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('institution settings avoids fixed light backgrounds', () {
    final source = File(
      'lib/features/auth/screens/institution_settings_screen.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('backgroundColor: Colors.white')));
    expect(source, isNot(contains('backgroundColor: const Color(0xFFFBF8FF)')));
    expect(
        source, isNot(contains('color: Colors.white,\n        borderRadius')));
    expect(source, isNot(contains('Color(0xFFF8FAFC)')));
    expect(source, isNot(contains('Color(0xFFF4F2FC)')));
    expect(source, isNot(contains('Color(0xFFE2E8F0)')));
    expect(source, isNot(contains('Color(0xFFC4C5D5)')));
  });
}
