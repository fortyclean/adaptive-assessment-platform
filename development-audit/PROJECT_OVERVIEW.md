# Project overview — development audit

Date: 2026-07-03  
Scope: Phase 0 discovery and Phase 1 stable baseline only. No production deployment, no GitHub push.

## Structure

| Area | Finding |
|---|---|
| Mobile | Flutter app under `mobile/` |
| Backend | Node.js + TypeScript API under `backend/` |
| State management | Flutter Riverpod |
| Navigation | `go_router` |
| API layer | Dio-based Flutter API clients and Express backend routes/services |
| Local storage | `flutter_secure_storage`, `shared_preferences`, Hive-related dependencies |
| Database/cache | MongoDB 7.0 and Redis 7.2 in Docker configs |
| Integrations | OneSignal and Sentry packages are present and env-driven |
| CI | GitHub Actions for secret scan, Flutter analyze/test, backend build/test/lint, and manual/tag APK build |

## Versions discovered

| Tool | Version / source |
|---|---|
| Flutter local | 3.44.4 stable |
| Dart | 3.12.2 |
| Flutter in CI | 3.44.4 |
| Node local | 24.17.0 |
| Node in CI | 22 LTS |
| npm | 11.13.0 |
| Java shell | 26.0.1 |
| Java used by Flutter/Gradle | Temurin 17.0.19 |
| Gradle | 8.14 |
| Kotlin Gradle Plugin | 2.0.21 |
| MongoDB Docker | 7.0 |
| Redis Docker | 7.2-alpine |

## Strengths

- Large Flutter and backend test suites are already present.
- Parent role is implemented across mobile/backend with regression coverage.
- Production-secret scan exists and passed in this run.
- Build artifacts can be produced locally for Android arm64.
- Backend contract tests cover auth, parent access, CORS, rate-limit, and error contracts.

## Primary risks

- Node policy is now explicit: CI/release use Node 22 LTS, while local Node 24 is acceptable for smoke checks until a newer LTS is adopted.
- Release workflow still contains demo credentials in generated release notes.
- Universal release APK failed locally because Windows Application Control blocked `gen_snapshot.exe` for android-x64.
- Backend lint passes with warnings, but 98 warnings remain.
- Flutter doctor reports unaccepted Android licenses, missing Chrome, and missing Visual Studio.
