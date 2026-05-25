import 'package:adaptive_assessment/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads Arabic localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('ar', 'SA'),
        labelBuilder: (context) =>
            '${AppLocalizations.of(context).appLanguage} / ${AppLocalizations.of(context).logout}',
      ),
    );

    expect(find.text('لغة التطبيق / تسجيل الخروج'), findsOneWidget);
  });

  testWidgets('loads English localization labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) =>
            '${AppLocalizations.of(context).appLanguage} / ${AppLocalizations.of(context).logout}',
      ),
    );

    expect(find.text('App language / Log out'), findsOneWidget);
  });

  testWidgets('formats localized version labels', (tester) async {
    await tester.pumpWidget(
      _LocalizedLabelApp(
        locale: const Locale('en', 'US'),
        labelBuilder: (context) =>
            AppLocalizations.of(context).versionLabel('1.0.70'),
      ),
    );

    expect(find.text('Version 1.0.70 — EduAssess'), findsOneWidget);
  });
}

class _LocalizedLabelApp extends StatelessWidget {
  const _LocalizedLabelApp({
    required this.locale,
    required this.labelBuilder,
  });

  final Locale locale;
  final String Function(BuildContext context) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) => Directionality(
          textDirection: Directionality.of(context),
          child: Text(labelBuilder(context)),
        ),
      ),
    );
  }
}
