# Android Permissions Audit

Version: 1.0.72

## Current Manifest Review

| Manifest | Permission | Status | Notes |
|---|---|---|---|
| `mobile/android/app/src/main/AndroidManifest.xml` | `android.permission.INTERNET` | Required | Needed for API calls, auth, notifications, and content loading. |
| `mobile/android/app/src/main/AndroidManifest.xml` | `android.permission.ACCESS_NETWORK_STATE` | Required | Needed to detect connectivity and show offline/error states. |
| `mobile/android/app/src/debug/AndroidManifest.xml` | `android.permission.INTERNET` | Debug only | Required by Flutter tooling for hot reload/debugging. |
| `mobile/android/app/src/profile/AndroidManifest.xml` | `android.permission.INTERNET` | Profile only | Required by Flutter tooling during profiling. |

## Findings

- No camera, contacts, microphone, location, SMS, phone, calendar, or storage permissions are requested in the main release manifest.
- Cleartext traffic is disabled in the release manifest via `android:usesCleartextTraffic="false"`.
- The launcher activity is exported because it has the launcher intent filter; this is expected.
- The `PROCESS_TEXT` query exists for Flutter text processing and is not a dangerous runtime permission.

## Release Gate

Before each store release:

1. Run `aapt dump permissions adaptive-mastery-vX.X.X.apk`.
2. Confirm only expected permissions are present.
3. Confirm new plugins did not add dangerous permissions implicitly.
4. If Firebase/OneSignal adds notification permission on Android 13+, document why it is needed and show a first-run permission rationale.
