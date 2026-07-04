# Issues register

## ISSUE-001

| Field | Value |
|---|---|
| Title | CI Flutter version differs from local Flutter version |
| Priority | P2 |
| Area | Build / CI |
| Severity | Medium |
| User value | Prevents “works locally, fails in CI” drift |
| Location | `.github/workflows/*.yml`, local Flutter |
| Current result | CI Flutter pin is now updated to 3.44.4 locally; previous pin was 3.35.7 |
| Expected result | One approved Flutter version is documented and used consistently |
| Root cause | Toolchain upgrades were applied locally without updating CI pin |
| Proposed fix | Update CI/toolchain docs after a compatibility pass, or downgrade local command path to the CI version |
| Acceptance | CI and local baseline run on the same Flutter version |
| Tests | `flutter analyze`, `flutter test`, APK/AAB build, CI |
| Status | Fixed locally; needs CI verification after push |

## ISSUE-002

| Field | Value |
|---|---|
| Title | Release workflow includes demo credentials in release notes |
| Priority | P1 |
| Area | Security / Release |
| Severity | High |
| User value | Prevents publishing credentials-like demo information in public release metadata |
| Location | `.github/workflows/build-apk.yml` |
| Current result | Release body includes demo usernames/passwords and mojibake text |
| Expected result | Release notes contain no login credentials and are cleanly encoded |
| Root cause | Legacy release-note body predates current release rules |
| Proposed fix | Replace body with safe installation notes and point testers to a private test-account document |
| Acceptance | Workflow contains no demo passwords in release notes |
| Tests | `node scripts/verify-release-notes-safe.mjs`, `node scripts/verify-no-production-secrets.mjs`, workflow inspection |
| Status | Fixed and locally verified |

## ISSUE-003

| Field | Value |
|---|---|
| Title | Universal release APK build blocked by Windows Application Control for android-x64 snapshot |
| Priority | P2 |
| Area | Local build environment |
| Severity | Medium |
| User value | Keeps local release builds reproducible |
| Location | Flutter toolchain under `C:\Users\eng_e\Downloads\flutter` |
| Current result | Universal APK failed when `gen_snapshot.exe` for android-x64 was blocked |
| Expected result | Universal APK builds, or release process intentionally builds ABI-specific artifacts |
| Root cause | Host application-control policy blocks one Flutter engine executable path |
| Proposed fix | Install/allow Flutter in an approved toolchain path or standardize on arm64 APK + AAB for local validation |
| Acceptance | Universal APK builds successfully, or documented ABI-specific release path is approved |
| Tests | `flutter build apk --release`; `flutter build apk --release --target-platform android-arm64` |
| Status | Discovered; arm64 workaround verified |

## ISSUE-004

| Field | Value |
|---|---|
| Title | Backend lint has 98 warnings |
| Priority | P3 |
| Area | Code quality |
| Severity | Low/Medium |
| User value | Improves maintainability and reduces future bug risk |
| Location | Backend routes/services |
| Current result | `npm run lint` passes with 0 warnings after the final cleanup batch; previous baselines were 98, 90, 85, 79, 77, then 38 warnings |
| Expected result | Lint warning budget is reduced or enforced |
| Root cause | Non-null assertions, unused variables, and console usage remain in legacy routes/services |
| Proposed fix | Fix warnings in small route/service batches with tests |
| Acceptance | Warning count reduced and no behavior regression |
| Tests | `npm run lint`, `npm run build`, `npm test -- --runInBand` |
| Status | Fixed locally — cleanup batches reduced warning count by 98 |

## ISSUE-005

| Field | Value |
|---|---|
| Title | Flutter doctor environment is not fully clean |
| Priority | P3 |
| Area | Developer environment |
| Severity | Low |
| User value | Reduces friction for local and device testing |
| Location | Local machine |
| Current result | Android licenses not fully accepted; Chrome and Visual Studio missing |
| Expected result | Android license checks pass; unsupported platforms are documented if intentionally unused |
| Root cause | Local environment setup gaps |
| Proposed fix | Accept Android licenses and document that web/Windows desktop are out of current mobile scope, or install required tools |
| Acceptance | `flutter doctor -v` has no Android blocker for Android work |
| Tests | `flutter doctor -v` |
| Status | Discovered |

## ISSUE-006

| Field | Value |
|---|---|
| Title | Docker development compose uses simple local credentials |
| Priority | P3 |
| Area | Security / Environment |
| Severity | Medium if reused outside local |
| User value | Prevents accidental reuse of development credentials |
| Location | `backend/docker-compose.yml`, root `docker-compose.yml` |
| Current result | Development compose files include local-only placeholder credentials |
| Expected result | Clearly marked local-only credentials and separate staging/production examples |
| Root cause | Local development compose is used as convenience configuration |
| Proposed fix | Keep only local examples in Git; enforce env-file usage for staging/production |
| Acceptance | No production-like credentials in tracked compose files |
| Tests | Secret scan and manual compose review |
| Status | Discovered |

## ISSUE-007

| Field | Value |
|---|---|
| Title | npm audit reports dependency vulnerabilities |
| Priority | P2 |
| Area | Dependency security |
| Severity | Medium/High pending package triage |
| User value | Reduces known dependency risk before Beta |
| Location | `backend/package-lock.json` |
| Current result | Non-forced remediation plus `uuid` removal and `xlsx` replacement reduced backend npm audit findings from 11 vulnerabilities to 0 |
| Expected result | Dependency vulnerabilities are triaged and fixed without breaking backend behavior |
| Root cause | Transitive dependency versions needed review/upgrades and spreadsheet parsing used a package with no audit fix |
| Proposed fix | Completed: use `crypto.randomUUID()` and `read-excel-file`; keep spreadsheet uploads limited to `.xlsx` |
| Acceptance | Audit report is clean with backend build/tests passing |
| Tests | `npm audit --json`, `npm run build`, `npm test -- --runInBand` |
| Status | Fixed locally; pending CI verification after push |
