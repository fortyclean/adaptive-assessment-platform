# Sentry Beta validation

Use this checklist only with an authorized Beta `SENTRY_DSN`. Do not commit the
DSN, paste it into issue comments, or share it in logs.

## Build configuration

Build the Beta with a DSN supplied at build time:

```powershell
flutter build apk --release `
  --dart-define=SENTRY_DSN="<authorized-beta-dsn>" `
  --dart-define=APP_ENV="beta" `
  --dart-define=APP_RELEASE="1.0.103"
```

## Privacy expectations

The app Sentry configuration must remain:

- `sendDefaultPii = false`
- `attachScreenshot = false`
- `tracesSampleRate = 0`
- no user email, phone, username, access token, refresh token, notification
  payload, or request body attached to the event

## Safe synthetic event

The app exposes a privacy-safe validation event through:

```dart
CrashReportingService.instance.captureSyntheticValidationEvent()
```

Expected Sentry event message:

```text
Bad state: release-validation-synthetic-event
```

This static event is intentionally free of personal data. After sending it,
verify the event arrives in the Beta Sentry project and attach only
non-sensitive proof to the release evidence.

## Evidence to keep

- event timestamp;
- environment = `beta`;
- release = configured `APP_RELEASE`;
- screenshot with project/event IDs redacted if needed;
- statement that no PII, payloads, or tokens were present.
