import 'package:adaptive_assessment/shared/services/crash_reporting_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('crash reporting stays disabled without a SENTRY_DSN', () async {
    final service = CrashReportingService.instance;

    expect(service.isEnabled, isFalse);
    await service.init();
    await service.captureException(
      StateError('test exception'),
      stackTrace: StackTrace.current,
    );
    await service.captureSyntheticValidationEvent();
  });

  test('synthetic validation event uses a static non-sensitive message', () {
    expect(
      CrashReportingService.syntheticValidationMessage,
      'release-validation-synthetic-event',
    );
    expect(CrashReportingService.syntheticValidationMessage, isNot(contains('@')));
    expect(
      CrashReportingService.syntheticValidationMessage,
      isNot(contains(RegExp(r'\d{6,}'))),
    );
  });
}
