# Release Gate Checklist

Use this checklist before creating any new signed APK or App Bundle. A version change is permitted only after every required gate is satisfied and an approved distributable is requested.

## Required automated gates

- [ ] `node scripts/verify-no-production-secrets.mjs` passes and no production environment file is tracked.
- [ ] `flutter analyze` finishes with no issues.
- [ ] `flutter test` finishes successfully.
- [ ] `npm run build` succeeds in `backend/`.
- [ ] `npm test -- --silent` succeeds in `backend/`.

## Required Android validation

- [ ] Android SDK licenses are accepted by an authorized developer.
- [ ] A physical Android device or configured AVD is detected by `flutter devices`.
- [ ] Student, teacher, and administrator smoke journeys are recorded: sign-in, dashboard, primary action, and sign-out.
- [ ] Offline, API-error, loading, and empty-state behavior is checked on-device.
- [ ] When configured for the beta environment, OneSignal permission, opt-in/out, registration, and a test push are verified.
- [ ] When configured for the beta environment, Sentry receives a safe synthetic exception with no sensitive fields.
- [ ] Screenshots and logcat evidence are saved under `qa-artifacts/release-validation/`.

## Artifact and approval gates

- [ ] The target package ID, versionCode/versionName, signing certificate, and SHA-256 are independently verified.
- [ ] The artifact-size decision (APK, App Bundle, or ABI split) is based on a measured result.
- [ ] The release evidence report contains only completed checks and known blockers.
- [ ] An authorized release owner has approved the new distributable.

If any box remains unchecked, do not change the application version and do not create a new release artifact.
