import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_assessment/core/constants/app_version.dart';

void main() {
  group('AppVersion', () {
    test('current version matches pubspec contract', () {
      expect(AppVersion.current, '1.0.111');
      expect(AppVersion.buildNumber, 111);
      expect(AppVersion.display, contains('1.0.111'));
      expect(AppVersion.display, contains('(111)'));
    });

    test('changelog head matches current release', () {
      final latest = AppVersion.changelog.first;
      expect(latest.version, AppVersion.current);
      expect(latest.buildNumber, AppVersion.buildNumber);
    });

    test('latest changelog entries are Arabic-facing', () {
      final latestEntries = AppVersion.changelog.take(3);

      for (final entry in latestEntries) {
        expect(entry.date, matches(RegExp(r'(يونيو|يوليو)')));
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
