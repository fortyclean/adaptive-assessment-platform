# Production readiness

Current recommendation: not ready for Production.

## Reasons

- Beta environment is not yet fully validated.
- OneSignal and Sentry Beta evidence is incomplete.
- Production separation and production demo-account blocking require a dedicated implementation/verification phase.
- Release workflow demo credentials were removed locally; the fix still needs commit/CI verification before any release.
- Backup/restore, rollback, monitoring, and migration plans still need final evidence.

## Minimum condition to reconsider

- No P0/P1 issues.
- CI green on the release commit.
- Flutter/backend tests green.
- AAB verified.
- Staging/Beta validation complete.
- Privacy/Terms/rollback/monitoring evidence documented.
