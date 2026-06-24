import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final router = File('lib/core/router/app_router.dart').readAsStringSync();

  test('previously unreachable teacher screens have canonical routes', () {
    expect(router, contains("name: 'teacherPendingEssays'"));
    expect(router, contains('PendingEssaysScreen'));
    expect(router, contains("name: 'teacherEssayGrading'"));
    expect(router, contains('EssayGradingScreen'));
    expect(router, contains("name: 'teacherQuestionQuality'"));
    expect(router, contains('QualityIndicatorScreen'));
  });

  test('all active notification routes use the canonical advanced center', () {
    expect(router, contains("name: 'notificationCenter'"));
    expect(router, contains("name: 'teacherNotifications'"));
    expect(router, contains("name: 'studentNotifications'"));
    expect(
      RegExp('AdvancedNotificationCenterScreen').allMatches(router).length,
      greaterThanOrEqualTo(3),
    );
  });
}
