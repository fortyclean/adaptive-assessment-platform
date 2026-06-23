import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final routerSource =
      File('lib/core/router/app_router.dart').readAsStringSync();

  void expectVariantRoute(String routeName, String screenClass) {
    final pattern = RegExp(
      "name: '$routeName',[\\s\\S]{0,900}?return $screenClass\\(",
    );
    expect(
      pattern.hasMatch(routerSource),
      isTrue,
      reason: '$routeName must expose its dedicated $screenClass.',
    );
  }

  test('exam variant routes preserve their dedicated reference screens', () {
    expectVariantRoute('studentExamWithImage', 'ExamWithImageScreen');
    expectVariantRoute('studentExamWithBookmark', 'ExamWithBookmarkScreen');
    expectVariantRoute(
      'studentExamWithTimerToggle',
      'ExamWithTimerToggleScreen',
    );
  });
}
