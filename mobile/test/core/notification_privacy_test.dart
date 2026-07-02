import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OneSignal verbose logging is debug-only and payloads are not logged',
      () {
    final source = File(
      'lib/shared/services/notification_service.dart',
    ).readAsStringSync();

    expect(source, contains('if (kDebugMode)'));
    expect(source, contains('OneSignal.Debug.setLogLevel(OSLogLevel.verbose)'));
    expect(source, isNot(contains('response.payload')));
    expect(source, isNot(contains('notification.payload')));
    expect(source, isNot(contains('subscriptionId)')));
    expect(source, isNot(contains('debugPrint(email')));
    expect(source, isNot(contains('debugPrint(phone')));
  });
}
