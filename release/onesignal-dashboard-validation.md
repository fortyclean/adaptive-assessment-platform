# OneSignal dashboard push validation

Use this checklist after installing an authorized Beta build on a physical
Android device. Do not paste OneSignal REST API keys, dashboard credentials,
player IDs, subscription IDs, emails, or phone numbers into release notes.

## Preconditions

- Beta build installed on the test device.
- Android notification permission granted by the user.
- The user has signed in or restored a session so the app can call:
  - `OneSignal.login(user.id)`
  - `OneSignal.User.addTags({'role': user.role.name})`
  - push subscription opt-in
- The backend `/push-subscriptions` endpoint has accepted the subscription.

## Dashboard test

1. Open the authorized OneSignal dashboard.
2. Select the Beta app/project only.
3. Create a test message with non-sensitive content, for example:

   ```text
   Release validation notification
   This is a safe Beta validation message.
   ```

4. Target only the test device or a safe internal test segment.
5. Send the notification.
6. Confirm the physical device receives it.
7. Tap the notification and confirm the app opens without printing payload or
   user identifiers in logcat.

## Non-sensitive evidence to keep

- build version and package ID;
- device model only, not serial number;
- timestamp of the dashboard send;
- redacted screenshot of the dashboard delivery state;
- redacted screenshot/photo of the received notification;
- logcat excerpt showing app open/tap handling with payloads and IDs redacted.

## Acceptance criteria

- permission is user-controlled and granted;
- push subscription is opted in;
- dashboard message is received on the physical device;
- tapping the notification opens the app;
- no notification payload, email, phone number, token, or subscription ID is
  stored in release notes or committed logs.
