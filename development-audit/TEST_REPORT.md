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
| `npm.cmd run lint` after `1.0.108` push | Failed with one Prettier error in `backend/src/routes/questions.ts`; fixed in `1.0.109+109` |
| `npm.cmd run lint` for `1.0.109` | Passed with existing warnings only; 0 errors |
| `npm.cmd run build` for `1.0.109` | Passed |
| `npm.cmd test -- --runInBand` for `1.0.109` | Passed — 20 suites / 470 tests |
| `npm.cmd audit --json` for `1.0.109` | Passed — 0 vulnerabilities |
| `flutter analyze` for `1.0.109+109` | Passed |
| `flutter test --reporter compact` for `1.0.109+109` | Passed — 346 tests |
| `flutter build apk --debug` for `1.0.109+109` | Passed |
| `adb install` for `1.0.109+109` | Blocked — connected Android phone disappeared from ADB/Flutter during install; empty evidence files were removed |
| `backend/tests/unit/excelImport.test.ts` generated `.xlsx` fixture | Passed — generated workbook parsed and empty row ignored |
| `npm.cmd run build` for `1.0.110` | Passed |
| `npm.cmd test -- --runInBand` for `1.0.110` | Passed — 20 suites / 471 tests |
| `npm.cmd run lint` for `1.0.110` | Passed with existing warnings only; 0 errors |
| `npm.cmd audit --json` for `1.0.110` | Passed — 0 vulnerabilities |
| `flutter analyze` for `1.0.110+110` | Passed |
| `flutter test --reporter compact` for `1.0.110+110` | Passed — 346 tests |
| `flutter build apk --debug` for `1.0.110+110` | Passed |
| Android install for `1.0.110+110` | Blocked — Android phone is not visible in ADB/Flutter |
| `backend/tests/integration/questionImportRoute.test.ts` for `1.0.111` | Passed — `.xlsx` upload accepted and legacy `.xls` rejected |
| `npm.cmd run lint` for `1.0.111` | Passed with existing warnings only; 0 errors |
| `npm.cmd run build` for `1.0.111` | Passed |
| `npm.cmd test -- --runInBand` for `1.0.111` | Passed — 21 suites / 473 tests |
| `npm.cmd audit --json` for `1.0.111` | Passed — 0 vulnerabilities |
| `flutter analyze` for `1.0.111+111` | Passed |
| `flutter test test/core/app_version_test.dart --reporter compact` for `1.0.111+111` | Passed — 3 tests |
| `flutter test --reporter compact` for `1.0.111+111` | Passed — 346 tests |
| `flutter build apk --debug` for `1.0.111+111` | Passed |
| `flutter run -d 78KNW19A25007947 --debug --no-resident` for `1.0.111+111` | Passed — debug APK installed/launched on `STK L21`; replaced incompatible prior signed build |
| `adb logcat` crash scan for `1.0.111+111` | Passed — no `FATAL EXCEPTION`, `E/flutter`, or `Unhandled Exception` markers found |
| Backend lint cleanup batch 73 | Passed — `npm.cmd run lint` warning count reduced from 98 to 90 with 0 errors |
| `npm.cmd run build` after lint cleanup batch 73 | Passed |
| `npm.cmd test -- --silent` after lint cleanup batch 73 | Passed — 21 suites / 473 tests |
| `npm.cmd audit --audit-level=moderate` after lint cleanup batch 73 | Passed — 0 vulnerabilities |
| Backend lint cleanup batch 74 | Passed — `npm.cmd run lint` warning count reduced from 90 to 85 with 0 errors |
| `npm.cmd run build` after lint cleanup batch 74 | Passed |
| Backend lint cleanup batch 75 | Passed — `npm.cmd run lint` warning count reduced from 85 to 79 with 0 errors |
| `npm.cmd run build` after lint cleanup batch 75 | Passed |
| Backend lint cleanup batch 76 | Passed — `npm.cmd run lint` warning count reduced from 79 to 77 with 0 errors |
| `npm.cmd run build` after lint cleanup batch 76 | Passed |
| Backend lint cleanup batch 77 | Passed — `npm.cmd run lint` warning count reduced from 77 to 38 with 0 errors |
| `npm.cmd run build` after lint cleanup batch 77 | Passed |
| `npm.cmd test -- --silent` after lint cleanup batch 77 | Passed — 21 suites / 473 tests |
| `npm.cmd audit --audit-level=moderate` after lint cleanup batch 77 | Passed — 0 vulnerabilities |
| Secret/release-note/diff checks after lint cleanup batch 77 | Passed |
| Backend lint cleanup final batch | Passed — `npm.cmd run lint` warning count reduced from 38 to 0 with 0 errors |
| `npm.cmd run build` after final backend lint cleanup | Passed |
| `npm.cmd test -- --silent` after final backend lint cleanup | Passed — 21 suites / 473 tests |
| `npm.cmd audit --audit-level=moderate` after final backend lint cleanup | Passed — 0 vulnerabilities |
| Secret/release-note/diff checks after final backend lint cleanup | Passed |
| `node scripts/init-release-evidence.mjs` after final backend lint cleanup | Passed — local evidence refreshed from CI run #92 / commit `e22723d` |
| `flutter run -d 78KNW19A25007947 --debug --no-resident` after final backend lint cleanup | Passed — debug APK built, installed, and launched on `STK L21` |
| `flutter screenshot -d 78KNW19A25007947` after Android launch | Passed — `qa-artifacts/release-validation/android-smoke-1.0.111-stk-l21.png` |
| `node scripts/verify-release-evidence.mjs` after Android install evidence update | Passed as a preview command — remaining blockers are role-smoke, notification permission, OneSignal dashboard push, Sentry event, and internal Beta approval evidence |
| Physical-device role smoke journeys for student/teacher/admin/parent | Passed — each role exited login/onboarding after demo role selection and skip; screenshots/XML saved under `qa-artifacts/release-validation/role-smoke-*-dashboard-1.0.111.*` |
| `node scripts/verify-release-evidence.mjs` after role-smoke evidence update | Passed as a preview command — remaining blockers are notification permission, OneSignal dashboard push, Sentry event, and internal Beta approval evidence |

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
  - `release-artifacts/adaptive-mastery-v1.0.110-debug.apk`
  - `release-artifacts/adaptive-mastery-v1.0.111-debug.apk`
  - `qa-artifacts/release-validation/logcat-1.0.111-debug-launch.txt`
  - `qa-artifacts/release-validation/screenshot-1.0.111-debug-launch.png`
