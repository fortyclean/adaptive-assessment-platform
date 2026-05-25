# OWASP Mobile Security Checklist

Version: 1.0.72

This checklist tracks the practical OWASP Mobile controls required before production release. It is intentionally written as a release gate, not a theoretical audit.

| Area | Current Control | Status | Next Action |
|---|---|---|---|
| Data storage | Tokens use secure storage in Flutter. | Implemented | Re-test logout/session restore before every release. |
| Transport security | Release manifest disables cleartext traffic. | Implemented | Verify API URLs are HTTPS in production builds. |
| Authentication | JWT + refresh flow exists with role-based guards. | Implemented | Add E2E session-expiry tests. |
| Authorization | Backend RBAC middleware exists. | Implemented | Add negative tests for every high-risk admin/teacher endpoint. |
| Secrets | Client secrets must not be printed, committed, or bundled unnecessarily. | Policy | Add secret scanning to CI. |
| Logging | Production must not log tokens, passwords, or student PII. | Needs CI gate | Add log-sanitization review to release checklist. |
| Input validation | Backend sanitization and validation exist. | Implemented | Keep validation tests with every new endpoint. |
| Rate limiting | API and auth rate limiters exist. | Implemented | Confirm production values in environment variables. |
| CORS | Wildcard CORS disables credentials; warning exists in production. | Partial | Configure explicit production origins before launch. |
| Error handling | Central error handler exists. | Implemented | Ensure production messages do not expose stack traces. |
| Anti-cheat | Exam navigation events are logged. | Implemented | Add tamper-resistant server-side evaluation for all question types. |
| Crash reporting | Not fully configured. | Open | Add Sentry or Firebase Crashlytics with PII scrubbing. |
| Push notifications | OneSignal service exists, production device verification remains. | Open | Verify subscription and delivery on physical devices. |
| Dependency safety | Manual dependency review only. | Partial | Add `npm audit` and Flutter dependency review to CI. |

## Production Blockers

- Configure explicit `CORS_ORIGIN` or `ALLOWED_ORIGINS` for production.
- Add crash reporting with privacy-safe event scrubbing.
- Add CI checks for analyze/test/build and secret scanning.
- Validate OneSignal production configuration on a real Android device.
