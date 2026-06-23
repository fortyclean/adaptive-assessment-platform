# Phase 5 — Local Validation Evidence

Last verified: 2026-06-23

This record contains only checks actually executed in the local workspace. It is not an approval to publish or build a new APK.

| Gate | Command / evidence | Result |
|---|---|---|
| Flutter static analysis | `flutter analyze` | Passed — no issues found |
| Flutter test suite | `flutter test --concurrency=1` | Passed — 372 tests succeeded |
| Backend compilation | `npm run build` | Passed |
| Backend test suite | `npm test -- --silent` | Passed — 18 suites, 455 tests |
| Production-secret guard | `node scripts/verify-no-production-secrets.mjs` | Passed |

## Android device validation

An Android 15 physical device was used for a Debug smoke test on 2026-06-23. Demo student, teacher, and administrator journeys completed sign-in, dashboard display, a role-specific primary navigation action, and sign-out. Evidence is in `qa-artifacts/release-validation/ANDROID_SMOKE_TEST.md` and adjacent screenshots, UI snapshots, and log output.

## Offline device validation

With Wi-Fi and mobile data temporarily disabled, the application reopened to its Arabic login/demo screen and the demo student dashboard completed without a crash. Network state was restored after the check. This validates offline demo entry and an explicit empty-assessment state; it does not validate a real backend API failure or slow response.

## Device performance baseline

Three Debug cold-launch samples on the physical Android device were 2288 ms, 2274 ms, and 2265 ms. The post-launch memory sample was 395395 KB total PSS. These are captured evidence, not a release performance acceptance target.

## Remaining release blockers

- On-device real backend API-failure and slow-loading validation have not been run.
- OneSignal validation requires an authorized beta configuration and test notification.
- Sentry validation requires an authorized DSN and a safe synthetic event.
- Isolated MongoDB/Redis contract testing, performance measurement, signing re-verification, and release evidence collection are pending.

No application version was changed and no new APK was built during this stabilization work.
