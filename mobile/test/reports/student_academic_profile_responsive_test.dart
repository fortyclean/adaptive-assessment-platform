import 'package:adaptive_assessment/core/theme/app_theme.dart';
import 'package:adaptive_assessment/features/reports/screens/student_academic_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('student academic profile renders on a small phone in dark mode',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const StudentAcademicProfileScreen(
            studentName: 'أحمد خالد',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('أحمد خالد'), findsOneWidget);
    expect(find.text('المعدل التراكمي'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('آخر نتائج الاختبارات'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('آخر نتائج الاختبارات'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
