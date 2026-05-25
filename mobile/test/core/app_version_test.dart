import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_assessment/core/constants/app_version.dart';

void main() {
  group('AppVersion', () {
    test('current version matches pubspec contract', () {
      expect(AppVersion.current, '1.0.74');
      expect(AppVersion.buildNumber, 74);
      expect(AppVersion.display, contains('1.0.74'));
      expect(AppVersion.display, contains('(74)'));
    });

    test('changelog head matches current release', () {
      final latest = AppVersion.changelog.first;
      expect(latest.version, AppVersion.current);
      expect(latest.buildNumber, AppVersion.buildNumber);
    });
  });
}
