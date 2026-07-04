# Changes made in this cycle

## Code/config changes

- Hardened the release evidence gate so every populated evidence path must point to an existing file under `qa-artifacts/release-validation/`, and text evidence is scanned for obvious secrets/PII before strict approval.
- Updated release evidence validation so Android notification permission is handled accurately: Android 13/API 33+ still requires a verified runtime permission, while Android 12/API 32 and below can be documented as `not_applicable_android_below_33` with non-sensitive ADB evidence.
- Captured Android 10 / SDK 29 notification-permission evidence for `STK L21`; the release gate now leaves only OneSignal dashboard push, Sentry Beta event, and internal Beta approval evidence as blockers.
- Completed physical-device role smoke evidence for student, teacher, admin, and parent on `STK L21`; release evidence now marks Android role smoke as passed while notification permission remains unverified after the device disappeared from ADB.
- Refreshed local release evidence from the latest successful CI run and verified the current debug APK installs and launches on physical Android device `STK L21`.
- Eliminated the remaining backend lint warning debt by replacing `req.user!` and fixture map non-null assertions with explicit guards/lookups, adding a defensive login-token check, and replacing the final startup `console.error` with `process.stderr.write`.
- Reduced backend lint warning debt from 77 to 38 by replacing `req.user!` with explicit authenticated-user guards in classrooms, users, report schedules, notifications, assessments, and questions routes.
- Reduced backend lint warning debt from 79 to 77 by replacing `req.user!` with an explicit authenticated-user guard in the per-student report route.
- Reduced backend lint warning debt from 85 to 79 by replacing `req.user!` with explicit authenticated-user guards in parent and student routes.
- Reduced backend lint warning debt from 90 to 85 by replacing `req.user!` with explicit authenticated-user guards in media, alerts, and push subscription routes.
- Reduced backend lint warning debt from 98 to 90 by removing unused imports, an unused encryption constant, and unused temporary variables without changing runtime behavior.
- Hardened `.github/workflows/deploy-backend.yml` so backend deployment validation now runs build, tests, lint, and dependency audit before reporting deployment readiness.
- Added the backend deployment workflow file to its own path trigger so changes to the gate are validated immediately.
- Bumped local mobile/backend version to `1.0.111+111`.
- Added API-level coverage for the question-bank `.xlsx` import upload route.
- Added rejection coverage to ensure legacy `.xls` uploads are blocked before the import service runs.
- Built, installed, and launched the `1.0.111+111` debug APK on the connected `STK L21` Android device with Logcat and screenshot evidence.
- Bumped local mobile/backend version to `1.0.110+110`.
- Added a generated `.xlsx` workbook parsing test for the question-bank import service.
- Added direct dev dependency coverage for `fflate` to create minimal XLSX fixtures in tests.
- Built `release-artifacts/adaptive-mastery-v1.0.110-debug.apk`; Android install remains pending because no phone is visible in ADB/Flutter.
- Bumped local mobile/backend version to `1.0.109+109`.
- Fixed backend Prettier lint formatting in the `.xlsx` upload MIME allow-list after CI reported the backend lint failure.
- Rebuilt the `1.0.109+109` debug APK locally; physical install is pending because the Android device disappeared from ADB/Flutter during install.
- Bumped local mobile/backend version to `1.0.108+108`.
- Replaced backend spreadsheet import parsing from vulnerable `xlsx` to `read-excel-file`.
- Limited question-bank spreadsheet uploads to `.xlsx` only and removed legacy `.xls` acceptance to avoid reintroducing the vulnerable parser surface.
- Reduced backend `npm audit` findings to zero known vulnerabilities.
- Built, installed, and launched the `1.0.108+108` debug APK on the connected `STK L21` Android device with Logcat and screenshot evidence.
- Bumped local mobile/backend version to `1.0.107+107`.
- Replaced backend `uuid` usage with Node `crypto.randomUUID()` and removed `uuid` / `@types/uuid` from backend dependencies.
- Reduced backend dependency audit findings to the remaining documented `xlsx` advisory.
- Built, installed, and launched the `1.0.107+107` debug APK on the connected `STK L21` Android device with Logcat and screenshot evidence.
- Bumped local mobile/backend version to `1.0.106+106`.
- Reduced backend dependency audit findings with non-forced npm remediation and `bcrypt` upgrade.
- Bumped local mobile/backend version to `1.0.105+105`.
- Added Node 22 toolchain policy files and aligned the backend deploy-check workflow with CI.
- Bumped local mobile version to `1.0.104+104`.
- Bumped local backend package version to `1.0.104`.
- Added `1.0.104` changelog entry for parent portal stabilization.
- Updated AppVersion tests to match `1.0.104`.
- Flutter automatically added Gradle compatibility flags:
  - `android.builtInKotlin=false`
  - `android.newDsl=false`

## Artifacts generated

- `release-artifacts/adaptive-mastery-v1.0.104-arm64.apk`
- `release-artifacts/adaptive-mastery-v1.0.104-arm64.aab`
- `development-audit/` reports

## Release workflow hardening

- Removed demo credentials and mojibake text from GitHub release notes.
- Added `scripts/verify-release-notes-safe.mjs` to block demo passwords or demo-login sections from release workflow text.
- Added the release-notes safety check to the CI `secrets` job.
- Aligned GitHub Actions Flutter setup from 3.35.7 to 3.44.4 to match the locally verified toolchain.

## Not done

- No signed release APK/AAB was generated for `1.0.110+110`; only debug device validation builds are being used during stabilization.
- No GitHub release.
- No production deployment.
- No production secret values added or printed.
