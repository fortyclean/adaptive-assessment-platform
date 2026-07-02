import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Production crash reporting facade.
///
/// Sentry is enabled only when `SENTRY_DSN` is provided at build time:
/// `--dart-define=SENTRY_DSN=https://public@sentry.example/project`.
class CrashReportingService {
  CrashReportingService._();

  static final CrashReportingService instance = CrashReportingService._();

  static const String syntheticValidationMessage =
      'release-validation-synthetic-event';

  static const String _dsn = String.fromEnvironment('SENTRY_DSN');
  static const String _environment =
      String.fromEnvironment('APP_ENV', defaultValue: 'production');
  static const String _release = String.fromEnvironment('APP_RELEASE');

  bool get isEnabled => _dsn.trim().isNotEmpty;

  Future<void> init() async {
    if (!isEnabled) return;

    await SentryFlutter.init(
      (options) {
        options.dsn = _dsn;
        options.environment = _environment;
        options.release = _release.isEmpty ? null : _release;
        options.sendDefaultPii = false;
        options.tracesSampleRate = 0;
        options.attachScreenshot = false;
      },
    );
  }

  void installGlobalHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      unawaited(captureFlutterError(details));
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(captureException(error, stackTrace: stack));
      return true;
    };
  }

  Future<void> captureFlutterError(FlutterErrorDetails details) async {
    if (!isEnabled) return;
    await Sentry.captureException(
      details.exception,
      stackTrace: details.stack,
    );
  }

  Future<void> captureException(
    Object error, {
    StackTrace? stackTrace,
  }) async {
    if (!isEnabled) return;
    await Sentry.captureException(error, stackTrace: stackTrace);
  }

  /// Sends a privacy-safe event that can be used to validate a Beta DSN.
  ///
  /// The event intentionally uses a static non-user message and no custom
  /// payload, email, phone number, username, token, or request data.
  Future<void> captureSyntheticValidationEvent() async {
    if (!isEnabled) return;
    await Sentry.captureException(
      StateError(syntheticValidationMessage),
      stackTrace: StackTrace.current,
    );
  }
}
