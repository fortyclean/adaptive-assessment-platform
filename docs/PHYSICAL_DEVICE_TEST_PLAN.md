# Physical Device Test Plan

> Target release: `1.0.76`
> Package: `com.adaptivemastery.app`

This checklist covers the tasks that cannot be fully verified by code, emulator,
or CI alone. Run it on at least one real Android phone before marking tasks
`39.4` and `41.4` as complete.

## 1. OneSignal Production Verification

Goal: verify real push notification delivery on an installed production APK.

Steps:

1. Use the latest signed release APK for `1.0.76`. If you are validating
   OneSignal specifically, build/install an APK with a real OneSignal app id:

   ```bash
   flutter build apk --release --dart-define=ONESIGNAL_APP_ID=YOUR_ONESIGNAL_APP_ID
   ```

2. Install the APK on a physical Android device.
3. Open the app and log in as a demo student, teacher, and admin in separate runs.
4. Accept notification permission when Android asks for it.
5. Confirm the device appears in the OneSignal dashboard as subscribed.
6. Send a test notification from OneSignal to the device.
7. Verify the notification appears while:
   - the app is open,
   - the app is in background,
   - the app is fully closed.
8. Tap the notification and confirm the app opens without crashing.
9. Trigger an assessment publish flow and confirm the target student receives a notification.
10. Trigger a result-ready or completion notification and confirm the target role receives it.

Pass criteria:

- device is registered once, without duplicate subscriptions;
- notifications arrive within a reasonable time;
- Arabic title/body render correctly;
- tapping a notification opens the app safely;
- no token, user id, or private payload is visible in user-facing text.

## 2. Install, Version, Signing, And Update Flow

Goal: verify the APK installs and updates correctly on real hardware.

Steps:

1. Install the previous signed APK version, for example `adaptive-mastery-v1.0.74.apk`.
2. Open it and verify demo login still works.
3. Install `adaptive-mastery-v1.0.76.apk` over it without uninstalling.
4. Confirm Android treats it as an update, not a different application.
5. Confirm the app opens after the update.
6. Confirm package and version:
   - package: `com.adaptivemastery.app`
   - versionCode: `76`
   - versionName: `1.0.76`
7. Confirm existing local session or settings do not break after update.
8. Test fresh install by uninstalling and reinstalling the APK.
9. Test the APK file received through WhatsApp/Drive if that is an expected distribution path.
10. If Android blocks install, verify the file is complete and signed, then retry from Files.

Pass criteria:

- APK installs as a valid package;
- update from previous version succeeds;
- app icon/name/package are unchanged;
- signing certificate stays the same as previous release;
- login, theme toggle, notifications screen, and core student navigation still work.

## 3. Minimum Device Matrix

Run this plan on:

- Android 10 or 11 low/mid device;
- Android 13+ device with notification runtime permission;
- a small screen device;
- a tablet if landscape support is part of the release acceptance.

## 4. Evidence To Keep

Store the following in the release notes or QA folder:

- device model and Android version;
- APK version tested;
- notification delivery screenshots;
- update install result;
- any crash/logcat snippet if a failure happens.

## 5. Report Back Template

Send the results back using this shape so blockers are easy to reproduce:

```text
Device:
Android version:
APK tested:
Install/update result:
Demo login admin/teacher/student:
Theme toggle:
Notifications screen:
OneSignal permission prompt:
OneSignal dashboard subscription:
Foreground notification:
Background notification:
Closed-app notification:
Notification tap result:
WhatsApp/Drive install result:
Any error text or screenshot:
```

If a step fails, include exactly what you tapped, what appeared, and whether the
APK was installed as a fresh install or as an update.
