import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'shared/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  // Initialize Hive for offline storage
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(AppConstants.pendingAnswersBoxName);
  await Hive.openBox<dynamic>(AppConstants.sessionStateBoxName);

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Restore session ───────────────────────────────────────────────────────
  // Keeps the user logged in when switching apps or restarting the device.
  final container = ProviderContainer();
  await _restoreSession(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AdaptiveAssessmentApp(),
    ),
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
    final user = await container
        .read(authRepositoryProvider)
        .restoreSession();
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

    return MaterialApp.router(
      title: 'منصة التقييم التكيفي',
      debugShowCheckedModeBanner: false,

      // ─── Theme ──────────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,

      // ─── Routing ────────────────────────────────────────────────────────
      routerConfig: router,

      // ─── Localization ────────────────────────────────────────────────────
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ─── RTL Text Direction ───────────────────────────────────────────────
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
