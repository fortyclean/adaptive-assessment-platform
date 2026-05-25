# Release Checklist

Version: 1.0.72

Use this checklist before generating any APK or sharing a build externally.

## Versioning

- [ ] Update `mobile/pubspec.yaml`.
- [ ] Update `backend/package.json` and `backend/package-lock.json`.
- [ ] Update `mobile/lib/core/constants/app_version.dart`.
- [ ] Update `.kiro/steering/project-rules.md`.
- [ ] Update `DEPLOY_GUIDE.md`.
- [ ] Update `دليل_استخدام_التطبيق.md`.

## Quality Gates

- [ ] `flutter pub get`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `npm run build`
- [ ] `npm test -- --silent`
- [ ] `flutter build apk --release --no-pub`

## APK Verification

- [ ] Copy APK to root as `adaptive-mastery-vX.X.X.apk`.
- [ ] Verify package name is `com.adaptivemastery.app`.
- [ ] Verify `versionCode` and `versionName`.
- [ ] Verify APK signature with `apksigner verify --print-certs`.
- [ ] Record SHA-256 file hash.
- [ ] Install on a physical Android device and test login, notifications, theme, and role navigation.

## Security and Privacy

- [ ] Confirm no secrets are printed in logs.
- [ ] Confirm no `client_secret` files are modified unless explicitly required.
- [ ] Confirm production API URL uses HTTPS.
- [ ] Confirm release permissions match `docs/ANDROID_PERMISSIONS_AUDIT.md`.
- [ ] Confirm privacy policy and terms links are available to users.

## GitHub

- [ ] Commit with a clear release message.
- [ ] Push to GitHub.
- [ ] Confirm remote branch includes the release commit.
