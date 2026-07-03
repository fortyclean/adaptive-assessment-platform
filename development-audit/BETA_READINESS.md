# Beta readiness

Current recommendation: not ready for closed Beta yet.

## Passed prerequisites

- Flutter analyze/tests pass locally.
- Backend build/tests pass locally.
- Android arm64 APK and AAB build locally.
- Secret scan passed.
- Parent portal stabilization is included in local version `1.0.104`.

## Blocking / pre-Beta items

1. Align CI/local Flutter versions and confirm CI success after version bump.
2. Re-run physical device smoke tests for version `1.0.104`.
3. Verify OneSignal and Sentry only in Beta with env variables, not committed values.
4. Confirm staging/Beta backend and database are isolated.
5. Keep release notes free of demo credentials through the new CI safety check.
