import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'l10n/app_localizations.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/services/crash_reporting_service.dart';
import 'shared/services/notification_service.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await CrashReportingService.instance.init();
    CrashReportingService.instance.installGlobalHandlers();

    // Initialize Hive for offline storage
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(AppConstants.pendingAnswersBoxName);
    await Hive.openBox<dynamic>(AppConstants.sessionStateBoxName);

    // Allow tablets to use landscape while keeping phones naturally responsive.
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    // ── Restore session ───────────────────────────────────────────────────────
    final container = ProviderContainer();

    // ── Initialize notifications ──────────────────────────────────────────────

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const AdaptiveAssessmentApp(),
      ),
    );

    unawaited(_restoreSessionAfterFirstFrame(container));
    unawaited(_initializeNotificationsAfterFirstFrame(container));
  }, (error, stack) async {
    await CrashReportingService.instance.captureException(
      error,
      stackTrace: stack,
    );
  });
}

Future<void> _restoreSessionAfterFirstFrame(ProviderContainer container) async {
  await WidgetsBinding.instance.endOfFrame;
  try {
    await _restoreSession(container);
  } catch (error, stack) {
    await CrashReportingService.instance.captureException(
      error,
      stackTrace: stack,
    );
  }
}

Future<void> _initializeNotificationsAfterFirstFrame(
  ProviderContainer container,
) async {
  await WidgetsBinding.instance.endOfFrame;
  try {
    await NotificationService.instance.init();
    await _syncRestoredPushUser(container);
  } catch (error, stack) {
    await CrashReportingService.instance.captureException(
      error,
      stackTrace: stack,
    );
  }
}

Future<void> _syncRestoredPushUser(ProviderContainer container) async {
  final user = container.read(authProvider).user;
  if (user == null) return;

  await NotificationService.instance.identifyPushUser(
    dio: container.read(apiServiceProvider).dio,
    user: user,
  );
}

/// Attempts to restore the user session from secure storage.
/// 1. If online: validates token with backend and refreshes user data.
/// 2. If offline: restores from cached user data so the app still opens.
Future<void> _restoreSession(ProviderContainer container) async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: AppConstants.accessTokenKey);
  if (token == null) return; // No previous session

  // Try online restore first
  try {
    final user = await container.read(authRepositoryProvider).restoreSession();
    if (user != null) {
      // Save user data for offline fallback
      await storage.write(
        key: AppConstants.userDataKey,
        value: jsonEncode(user.toJson()),
      );
      container.read(authProvider.notifier).setUser(user, token);
      return;
    }
    // Token invalid — clear storage
    await storage.delete(key: AppConstants.accessTokenKey);
    await storage.delete(key: AppConstants.refreshTokenKey);
    await storage.delete(key: AppConstants.userDataKey);
  } catch (_) {
    // Network unavailable — try offline restore from cached data
    final userJson = await storage.read(key: AppConstants.userDataKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final user = AuthUser.fromJson(userMap);
        container.read(authProvider.notifier).setUser(user, token);
      } catch (_) {
        // Corrupted cache — clear it
        await storage.delete(key: AppConstants.userDataKey);
      }
    }
  }
}

/// Root application widget.
class AdaptiveAssessmentApp extends ConsumerWidget {
  const AdaptiveAssessmentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      final previousUserId = previous?.user?.id;
      final nextUser = next.user;

      if (nextUser != null && previousUserId != nextUser.id) {
        NotificationService.instance.identifyPushUser(
          dio: ref.read(apiServiceProvider).dio,
          user: nextUser,
        );
      } else if (previousUserId != null && nextUser == null) {
        NotificationService.instance.clearPushUser();
      }
    });

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,

      // ─── Theme ──────────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // ─── Routing ────────────────────────────────────────────────────────
      routerConfig: router,

      // ─── Localization ────────────────────────────────────────────────────
      locale: locale,
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ─── RTL Text Direction ───────────────────────────────────────────────
      builder: (context, child) => Directionality(
        textDirection:
            locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
