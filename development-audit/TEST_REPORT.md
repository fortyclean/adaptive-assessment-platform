# Test report

## Commands executed

| Command | Result |
|---|---|
| `flutter doctor -v` | Completed with environment warnings |
| `flutter pub get` | Passed |
| `flutter analyze` | Passed |
| `flutter test --reporter compact` | Passed — 346 tests |
| `flutter build apk --debug` | Passed |
| `flutter build apk --release` | Failed for universal APK due Windows Application Control blocking android-x64 snapshot |
| `flutter build apk --release --target-platform android-arm64` | Passed |
| `flutter build appbundle --release --target-platform android-arm64` | Passed |
| `npm.cmd run build` | Passed |
| `npm.cmd test -- --runInBand` | Passed — 20 suites / 470 tests |
| `npm.cmd run lint` | Passed with 98 warnings |
| `node scripts/verify-no-production-secrets.mjs` | Passed |
| `node scripts/verify-release-notes-safe.mjs` | Passed |
| `flutter analyze` after release-note guard | Passed |
| `flutter test test/core/app_version_test.dart --reporter compact` | Passed — 3 tests |
| `rg "3\.35\.7\|flutter-version" -n .github development-audit` | Passed — workflow pins now show Flutter 3.44.4; historical note remains only in audit change log |
| `npm.cmd run build` after Node policy update | Passed |
| `npm.cmd test -- --runInBand` after Node policy update | Passed — 20 suites / 470 tests |

## Build evidence

- APK: `release-artifacts/adaptive-mastery-v1.0.104-arm64.apk`
- AAB: `release-artifacts/adaptive-mastery-v1.0.104-arm64.aab`
- APK package: `com.adaptivemastery.app`
- APK versionCode/versionName: `104` / `1.0.104`
- APK signing: v2 verified
- AAB signing: `jarsigner` verified
