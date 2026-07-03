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
| `npm.cmd audit fix` without `--force` | Reduced dependency findings from 11 to 4 |
| `npm.cmd install bcrypt@^6.0.0` | Reduced dependency findings from 4 to 2 |
| `npm.cmd uninstall uuid @types/uuid` | Removed deprecated UUID dependency; audit now reports only the documented `xlsx` advisory |
| `flutter analyze` for `1.0.107+107` | Passed |
| `flutter test --reporter compact` for `1.0.107+107` | Passed — 346 tests |
| `npm.cmd run build` for `1.0.107` | Passed |
| `npm.cmd test -- --runInBand` for `1.0.107` | Passed — 20 suites / 470 tests |
| `npm.cmd audit --json` for `1.0.107` | Reports only the documented direct `xlsx` high advisory with no npm fix available |
| `flutter build apk --debug` for `1.0.107+107` | Passed |
| `adb install -r ...app-debug.apk` on `STK L21` | Passed |
| `adb shell monkey -p com.adaptivemastery.app ...` | Passed; app launched |
| `npm.cmd uninstall xlsx` + `npm.cmd install read-excel-file@^9.2.0` | Passed; backend audit reports 0 vulnerabilities |
| `npm.cmd run build` for `1.0.108` | Passed |
| `npm.cmd test -- --runInBand` for `1.0.108` | Passed — 20 suites / 470 tests |
| `npm.cmd audit --json` for `1.0.108` | Passed — 0 vulnerabilities |
| `flutter analyze` for `1.0.108+108` | Passed |
| `flutter test --reporter compact` for `1.0.108+108` | Passed — 346 tests |
| `flutter build apk --debug` for `1.0.108+108` | Passed |
| `adb install -r ...app-debug.apk` on `STK L21` for `1.0.108+108` | Passed |
| `adb shell monkey -p com.adaptivemastery.app ...` for `1.0.108+108` | Passed; app launched without Logcat fatal exception |

## Build evidence

- APK: `release-artifacts/adaptive-mastery-v1.0.104-arm64.apk`
- AAB: `release-artifacts/adaptive-mastery-v1.0.104-arm64.aab`
- APK package: `com.adaptivemastery.app`
- APK versionCode/versionName: `104` / `1.0.104`
- APK signing: v2 verified
- AAB signing: `jarsigner` verified
- Debug launch evidence:
  - `qa-artifacts/release-validation/logcat-1.0.107-debug-launch.txt`
  - `qa-artifacts/release-validation/screenshot-1.0.107-debug-launch.png`
  - `qa-artifacts/release-validation/logcat-1.0.108-debug-launch.txt`
  - `qa-artifacts/release-validation/screenshot-1.0.108-debug-launch.png`
