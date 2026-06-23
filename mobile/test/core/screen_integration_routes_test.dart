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
}
