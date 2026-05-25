import 'package:adaptive_assessment/features/assessment/screens/student_subjects_screen.dart';
import 'package:adaptive_assessment/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('student subjects screen uses English localization labels',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en', 'US'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: StudentSubjectsScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Smart assessment'), findsOneWidget);
    expect(find.text('Search for a subject...'), findsOneWidget);
    expect(find.text('Progress achieved'), findsWidgets);
    expect(find.text('Start now'), findsOneWidget);
  });
}
