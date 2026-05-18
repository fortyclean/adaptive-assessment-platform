# iOS Testing Readiness

The current mobile workspace is Android-only; there is no `ios/` Flutter
platform folder in this checkout. A real iOS verification pass requires macOS,
Xcode, CocoaPods, Apple signing, and an iOS simulator or physical device.

When the iOS platform is generated, run this checklist:

- `flutter create --platforms=ios .`
- Configure bundle identifier and signing in Xcode.
- Add any push-notification provider files required by the selected provider.
- Run `flutter analyze` and `flutter test`.
- Run on iPhone SE, a current iPhone size, and iPad landscape.
- Verify login, account settings, theme toggle, notification center, and exam
  flow.
