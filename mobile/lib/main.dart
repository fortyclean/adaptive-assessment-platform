import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter error handler — prevents crash dialogs from propagating
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

  runApp(
    // ProviderScope enables Riverpod state management throughout the app
    const ProviderScope(
      child: AdaptiveAssessmentApp(),
    ),
  );
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
