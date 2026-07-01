import 'dart:io';

import 'package:adaptive_assessment/core/network/api_service.dart';
import 'package:adaptive_assessment/core/router/app_router.dart';
import 'package:adaptive_assessment/core/theme/app_theme.dart';
import 'package:adaptive_assessment/features/auth/repositories/auth_repository.dart';
import 'package:adaptive_assessment/features/auth/screens/login_screen.dart';
import 'package:adaptive_assessment/l10n/app_localizations.dart';
import 'package:adaptive_assessment/shared/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FailingAuthRepository extends AuthRepository {
  _FailingAuthRepository(this._failure) : super(ApiService.instance);

  final DioException _failure;

  @override
  Future<({String accessToken, AuthUser user})> login({
    required String username,
    required String password,
  }) async {
    throw _failure;
  }
}

Widget _buildLoginRouterApp({
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, __) => const Scaffold(body: Text('signup-route')),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const Scaffold(body: Text('forgot-route')),
      ),
      GoRoute(
        path: AppRoutes.studentDashboard,
        builder: (_, __) =>
            const Scaffold(body: Text('student-dashboard-route')),
      ),
      GoRoute(
        path: AppRoutes.teacherDashboard,
        builder: (_, __) =>
            const Scaffold(body: Text('teacher-dashboard-route')),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (_, __) => const Scaffold(body: Text('admin-dashboard-route')),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    ),
  );
}

AppLocalizations _l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(LoginScreen)));

Future<void> _submitCredentials(WidgetTester tester) async {
  final l10n = _l10n(tester);
  await tester.ensureVisible(find.byType(TextFormField).first);
  await tester.enterText(find.byType(TextFormField).first, 'student.demo');
  await tester.enterText(find.byType(TextFormField).last, 'Password123');
  await tester.ensureVisible(find.text(l10n.login));
  await tester.tap(find.text(l10n.login));
  await tester.pumpAndSettle();
}

Future<void> _tapDemoRole(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('Device quality gates — auth entry smoke coverage', () {
    testWidgets('keeps the Arabic login experience RTL', (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildLoginRouterApp());
      await tester.pumpAndSettle();

      final directionality =
          Directionality.of(tester.element(find.byType(LoginScreen)));
      expect(directionality, TextDirection.rtl);
      expect(find.text(_l10n(tester).login), findsOneWidget);
    });

    testWidgets('routes each demo role to the correct dashboard',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 1400));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildLoginRouterApp());
      await tester.pumpAndSettle();

      var l10n = _l10n(tester);
      await _tapDemoRole(tester, l10n.studentRole);
      expect(find.text('student-dashboard-route'), findsOneWidget);

      await tester.pumpWidget(_buildLoginRouterApp());
      await tester.pumpAndSettle();
      l10n = _l10n(tester);
      await _tapDemoRole(tester, l10n.teacherRole);
      expect(find.text('teacher-dashboard-route'), findsOneWidget);

      await tester.pumpWidget(_buildLoginRouterApp());
      await tester.pumpAndSettle();
      l10n = _l10n(tester);
      await _tapDemoRole(tester, l10n.adminRole);
      expect(find.text('admin-dashboard-route'), findsOneWidget);
    });

    testWidgets('shows a localized no-internet message on connection failure',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildLoginRouterApp(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              _FailingAuthRepository(
                DioException(
                  requestOptions: RequestOptions(path: '/auth/login'),
                  type: DioExceptionType.connectionError,
                  error: const SocketException('offline'),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final expectedMessage = _l10n(tester).loginNoInternet;
      await _submitCredentials(tester);

      expect(find.text(expectedMessage), findsOneWidget);
    });

    testWidgets('shows a localized invalid-credentials message on 401',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildLoginRouterApp(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              _FailingAuthRepository(
                DioException(
                  requestOptions: RequestOptions(path: '/auth/login'),
                  response: Response<Map<String, dynamic>>(
                    requestOptions: RequestOptions(path: '/auth/login'),
                    statusCode: 401,
                    data: {'status': 'error'},
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final expectedMessage = _l10n(tester).loginInvalidCredentials;
      await _submitCredentials(tester);

      expect(find.text(expectedMessage), findsOneWidget);
    });
  });
}
