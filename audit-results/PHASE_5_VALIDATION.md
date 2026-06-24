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

## Offline and API-failure device validation

With Wi-Fi and mobile data temporarily disabled, the application reopened to its Arabic login/demo screen and the demo student dashboard completed without a crash. Network state was restored after the check. A separate Debug build configured with an intentionally unreachable API showed a localized waiting state followed by a localized retryable server-waking message. These checks validate offline entry, an explicit empty-assessment state, and API loading/failure feedback on-device.

## Device performance baseline

Three Debug cold-launch samples on the physical Android device were 2288 ms, 2274 ms, and 2265 ms. The post-launch memory sample was 395395 KB total PSS. These are captured evidence, not a release performance acceptance target.

## Android artifact-size decision

The prior release APK (`1.0.99`) measured 69.32 MiB. A local `1.0.101` release App Bundle measured 52.57 MiB, a 16.75 MiB (about 24%) reduction in upload artifact size. App Bundle is therefore the preferred Play distribution format. This measurement build was not published and is not release approval.

## Remaining release blockers

- OneSignal validation requires an authorized beta configuration and test notification.
- Sentry validation requires an authorized DSN and a safe synthetic event.
- Isolated MongoDB/Redis contract testing, performance measurement, signing re-verification, and release evidence collection are pending.

No application version was changed and no new APK was built during this stabilization work.
