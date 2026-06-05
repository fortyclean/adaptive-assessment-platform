import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_assessment/core/constants/app_version.dart';

void main() {
  group('AppVersion', () {
    test('current version matches pubspec contract', () {
      expect(AppVersion.current, '1.0.98');
      expect(AppVersion.buildNumber, 98);
      expect(AppVersion.display, contains('1.0.98'));
      expect(AppVersion.display, contains('(98)'));
    });

    test('changelog head matches current release', () {
      final latest = AppVersion.changelog.first;
      expect(latest.version, AppVersion.current);
      expect(latest.buildNumber, AppVersion.buildNumber);
    });

    test('latest changelog entries are Arabic-facing', () {
      final latestEntries = AppVersion.changelog.take(3);

      for (final entry in latestEntries) {
        expect(entry.date, contains('يونيو'));
        expect(entry.title, isNot(contains('localization')));
        expect(entry.title, isNot(contains('dashboard')));
        expect(entry.title, isNot(contains('crash reporting')));

        for (final change in entry.changes) {
          expect(change, isNot(contains('Moved ')));
          expect(change, isNot(contains('Added ')));
          expect(change, isNot(contains('Improved ')));
          expect(change, isNot(contains('Documented ')));
        }
      }
    });
  });
}
