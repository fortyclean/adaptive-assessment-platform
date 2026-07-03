# Current status

## Baseline result

| Check | Result | Evidence |
|---|---|---|
| Git branch | `main...origin/main` | Local changes exist; nothing pushed in this review cycle |
| Flutter doctor | Completed with warnings | Android licenses, Chrome, Visual Studio |
| Flutter pub get | Passed | Dependencies resolved |
| Flutter analyze | Passed | No issues found |
| Flutter tests | Passed | 346 tests passed |
| Backend build | Passed | `tsc` completed |
| Backend tests | Passed | 20 suites / 470 tests passed |
| Backend lint | Passed with warnings | 0 errors / 98 warnings |
| Secret scan | Passed | `node scripts/verify-no-production-secrets.mjs` |
| Release notes safety scan | Passed | `node scripts/verify-release-notes-safe.mjs` |
| Debug APK | Passed | `app-debug.apk` built |
| Release APK | Passed for arm64 | `adaptive-mastery-v1.0.104-arm64.apk` |
| Release AAB | Passed for arm64 | `adaptive-mastery-v1.0.104-arm64.aab` |

## Version state

The app/backend version is being advanced to `1.0.105+105` for toolchain policy alignment after the `1.0.104` release baseline.

## Local artifacts

| Artifact | Size | SHA-256 |
|---|---:|---|
| `release-artifacts/adaptive-mastery-v1.0.104-arm64.apk` | 29,681,025 bytes | `7046BDE9A9DB1C677A1B467F1D6FA0D5352953C1CA3A77BFB00DAE3EE9020620` |
| `release-artifacts/adaptive-mastery-v1.0.104-arm64.aab` | 29,326,887 bytes | `7D38D73EB0545513F44C55927764EC9190C8AD6A079E5B09962171B5A08EBD01` |

APK package verification: `com.adaptivemastery.app`, versionCode `104`, versionName `1.0.104`, APK Signature Scheme v2 verified.

## Modified files

- `backend/package.json`
- `backend/package-lock.json`
- `mobile/pubspec.yaml`
- `mobile/lib/core/constants/app_version.dart`
- `mobile/test/core/app_version_test.dart`
- `mobile/android/gradle.properties` — Flutter auto-added migration compatibility flags.
- `.github/workflows/build-apk.yml` — release notes cleaned to remove demo credentials and mojibake text.
- `.github/workflows/ci.yml` — release-notes safety check added to CI and Flutter pin aligned to 3.44.4.
- `.github/workflows/build-apk.yml` — Flutter pin aligned to 3.44.4.
- `.github/workflows/deploy-backend.yml` — Node pin aligned to Node 22 and mojibake status text cleaned.
- `.nvmrc` / `.node-version` — Node 22 policy files added.
- `scripts/verify-release-notes-safe.mjs` — new guard against publishing demo credentials in release notes.
