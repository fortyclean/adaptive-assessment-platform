# Internal Beta Runbook

## Scope

This runbook covers the final human-operated release gate after automated build, test, signing,
and device checks pass.

## Required artifacts

- Signed APK or AAB path.
- SHA-256 hash.
- Version name and version code.
- Backend build/test result.
- Flutter analyze/test result.
- Physical-device smoke evidence.
- OneSignal dashboard push evidence, if notifications are in scope.
- Sentry synthetic-event evidence, if a Beta DSN is in scope.

## Internal Beta steps

1. Upload the signed AAB to the internal testing track.
2. Confirm package ID, signing certificate, version code, and version name before rollout.
3. Add testers for the three core roles: administrator, teacher, and student.
4. Install from the internal track on at least one physical Android device.
5. Run role smoke checks:
   - Login.
   - Role dashboard.
   - Primary action.
   - Notifications/settings check.
   - Logout.
6. Record non-sensitive evidence in `qa-artifacts/release-validation/`.

## Release evidence gate

1. Initialize the local evidence file:

   ```powershell
   node scripts/init-release-evidence.mjs
   ```

   This fills the latest successful CI result automatically when GitHub Actions
   is reachable. If offline, copy `release/release-evidence-template.json` to:

   ```text
   qa-artifacts/release-validation/release-evidence.json
   ```

2. Fill the remaining OneSignal, Sentry, Android, and internal Beta fields with
   non-sensitive evidence only. For Android notification permission, set
   `notificationPermissionGranted: true` only after verifying the runtime
   permission on Android 13/API 33 or newer. On Android 12/API 32 and older,
   set `notificationPermissionStatus: not_applicable_android_below_33` and add a
   non-sensitive ADB evidence path, because `POST_NOTIFICATIONS` is not a
   runtime permission on those Android versions.
   Every `evidencePath` must point to an existing file under
   `qa-artifacts/release-validation/`. Text evidence is automatically scanned for
   obvious secrets and personal data before the strict gate can pass.
3. Run the non-blocking preview:

   ```powershell
   node scripts/verify-release-evidence.mjs
   ```

4. Run the strict release gate before promoting the Beta:

   ```powershell
   node scripts/verify-release-evidence.mjs --strict
   ```

The strict gate must pass before the release owner approval is considered
complete.

## Rollback plan

- Stop rollout from the store console.
- Re-promote the previous known-good version if needed.
- Notify testers and support with the affected version code and known symptoms.
- Keep server migrations backward-compatible until the Beta is approved.

## Support checklist

- Support contact is listed in store metadata.
- Known issues and test scope are sent to internal testers.
- Crash and push dashboards are monitored during the Beta window.
- Any tester-reported issue gets a severity, owner, and reproduction notes.

## Approval

The release owner must approve:

- Automated gates passed.
- Signed artifact verified.
- Physical-device smoke passed.
- No unresolved critical or high-risk issue remains.
- Rollback owner and support owner are named.

Do not promote to a wider track until this approval is documented.
