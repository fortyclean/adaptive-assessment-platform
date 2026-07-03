# Changes made in this cycle

## Code/config changes

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

- No signed release APK/AAB was generated for `1.0.108+108`; only a debug device validation build was installed.
- No GitHub release.
- No production deployment.
- No production secret values added or printed.
