import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_assessment/core/constants/app_version.dart';

void main() {
  group('AppVersion', () {
    test('current version matches pubspec contract', () {
      expect(AppVersion.current, '1.0.52');
      expect(AppVersion.buildNumber, 52);
      expect(AppVersion.display, contains('1.0.52'));
      expect(AppVersion.display, contains('(52)'));
    });

    test('changelog head matches current release', () {
      final latest = AppVersion.changelog.first;
      expect(latest.version, AppVersion.current);
      expect(latest.buildNumber, AppVersion.buildNumber);
    });
  });
}
