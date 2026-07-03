import 'package:adaptive_assessment/core/router/app_router.dart';
import 'package:adaptive_assessment/core/constants/app_colors.dart';
import 'package:adaptive_assessment/core/theme/app_theme.dart';
import 'package:adaptive_assessment/features/parent/screens/parent_portal_screens.dart';
import 'package:adaptive_assessment/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _buildParentRouterApp(
    {String initialLocation = AppRoutes.parentDashboard}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.parentDashboard,
        builder: (_, __) => const ParentDashboardScreen(),
        routes: [
          GoRoute(
            path: 'children',
            builder: (_, __) => const ParentChildrenScreen(),
            routes: [
              GoRoute(
                path: ':childId',
                builder: (_, state) => ParentChildDetailScreen(
                  childId: state.pathParameters['childId'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'messages',
            builder: (_, __) => const ParentMessagesScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (_, __) => const ParentSettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('notification-settings'))),
      ),
      GoRoute(
        path: AppRoutes.accountSettings,
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('account-settings'))),
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme.copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      routerConfig: router,
    ),
  );
}

Future<void> _tapVisibleText(WidgetTester tester, String text) async {
  final textFinder = find.text(text).last;
  await tester.ensureVisible(textFinder);
  final inkWell = find.ancestor(of: textFinder, matching: find.byType(InkWell));
  final gestureDetector =
      find.ancestor(of: textFinder, matching: find.byType(GestureDetector));

  if (inkWell.evaluate().isNotEmpty) {
    await tester.tap(inkWell.first);
  } else if (gestureDetector.evaluate().isNotEmpty) {
    await tester.tap(gestureDetector.first);
  } else {
    await tester.tap(textFinder, warnIfMissed: false);
  }
  await _pumpPortalFrame(tester);
}

Future<void> _pumpPortalFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  group('Parent portal integration', () {
    testWidgets('renders the parent dashboard with children and messages',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildParentRouterApp());
      await _pumpPortalFrame(tester);

      expect(find.text('بوابة ولي الأمر'), findsOneWidget);
      expect(find.text('ملخص الأبناء'), findsOneWidget);
      expect(find.text('سارة أحمد'), findsOneWidget);
      expect(find.text('آخر الرسائل'), findsOneWidget);
      expect(find.text('الأبناء'), findsWidgets);
      expect(find.text('الرسائل'), findsWidgets);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('uses the shared product color system on parent cards',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildParentRouterApp());
      await _pumpPortalFrame(tester);

      final brandedHeroCard = find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        if (decoration is! BoxDecoration) return false;
        return decoration.color == AppColors.primary.withValues(alpha: 0.10);
      });

      expect(brandedHeroCard, findsOneWidget);
    });

    testWidgets('navigates from dashboard to children and child detail',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildParentRouterApp());
      await _pumpPortalFrame(tester);

      await _tapVisibleText(tester, 'عرض الكل');
      expect(find.text('الأبناء'), findsWidgets);

      await _tapVisibleText(tester, 'سارة أحمد');
      expect(find.text('توصية المتابعة'), findsOneWidget);
      expect(find.text('اختبار قريب'), findsOneWidget);
    });

    testWidgets('bottom navigation opens messages and settings',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildParentRouterApp());
      await _pumpPortalFrame(tester);

      await _tapVisibleText(tester, 'الرسائل');
      expect(find.text('رسائل ولي الأمر'), findsOneWidget);

      await _tapVisibleText(tester, 'الإعدادات');
      expect(find.text('إعدادات ولي الأمر'), findsOneWidget);

      await _tapVisibleText(tester, 'إعدادات الإشعارات');
      expect(find.text('notification-settings'), findsOneWidget);
    });
  });
}
