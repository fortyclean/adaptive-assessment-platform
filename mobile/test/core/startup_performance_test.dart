import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Startup performance guard', () {
    test(
        'main renders the Flutter app before session restore and notifications',
        () {
      final mainSource = File('lib/main.dart').readAsStringSync();

      final runAppIndex = mainSource.indexOf('runApp(');
      final restoreIndex =
          mainSource.indexOf('unawaited(_restoreSessionAfterFirstFrame');
      final notificationsIndex = mainSource
          .indexOf('unawaited(_initializeNotificationsAfterFirstFrame');
      final blockingStartupSegment = mainSource.substring(0, runAppIndex);

      expect(runAppIndex, isNonNegative);
      expect(restoreIndex, greaterThan(runAppIndex));
      expect(notificationsIndex, greaterThan(runAppIndex));
      expect(
        blockingStartupSegment,
        isNot(contains('await _restoreSession(container);')),
      );
      expect(
        blockingStartupSegment,
        isNot(contains('await NotificationService.instance.init();\n'
            '    await _syncRestoredPushUser(container);')),
      );
    });

    test('Android launch surface uses the light app surface instead of blue',
        () {
      for (final path in [
        'android/app/src/main/res/drawable/launch_background.xml',
        'android/app/src/main/res/drawable-v21/launch_background.xml',
      ]) {
        final xml = File(path).readAsStringSync();

        expect(xml, contains('#FBF8FF'));
        expect(xml, isNot(contains('#00288E')));
      }
    });
  });
}
