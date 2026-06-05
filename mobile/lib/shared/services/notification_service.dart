import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../providers/auth_provider.dart';

/// Manages local notifications and prepares push-notification expansion.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  static const String _oneSignalAppId =
      String.fromEnvironment('ONESIGNAL_APP_ID');

  static const AndroidNotificationDetails _instantAndroidDetails =
      AndroidNotificationDetails(
    'default_channel',
    'Notifications',
    channelDescription: 'Instant performance and report notifications',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  static const AndroidNotificationDetails _scheduledAndroidDetails =
      AndroidNotificationDetails(
    'scheduled_channel',
    'Scheduled notifications',
    channelDescription: 'Scheduled report and event notifications',
    importance: Importance.high,
    priority: Priority.high,
  );

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _remoteInitialized = false;
  bool _pushObserverAttached = false;
  bool _registeringPushToken = false;
  String? _lastRegisteredSubscriptionId;
  Dio? _pushDio;
  AuthUser? _pushUser;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint('Notification tapped: ${response.payload ?? 'no-payload'}');
      },
    );

    await requestNotificationPermission();
    _initialized = true;

    await _initOneSignalIfConfigured();
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  Future<bool?> requestNotificationPermission() async {
    final androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return androidImplementation?.requestNotificationsPermission();
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _ensureInitialized();
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: _instantAndroidDetails),
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await _ensureInitialized();
    if (!scheduledTime.isAfter(DateTime.now())) {
      throw ArgumentError.value(
        scheduledTime,
        'scheduledTime',
        'Scheduled notifications must be in the future.',
      );
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime.toLocal(), tz.local),
      const NotificationDetails(android: _scheduledAndroidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _ensureInitialized();
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _ensureInitialized();
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  bool get isRemotePushConfigured => _oneSignalAppId.trim().isNotEmpty;

  Future<void> identifyPushUser({
    required Dio dio,
    required AuthUser user,
  }) async {
    _pushDio = dio;
    _pushUser = user;

    if (!isRemotePushConfigured) return;

    await _ensureInitialized();
    await _initOneSignalIfConfigured();

    try {
      await OneSignal.login(user.id);
      await OneSignal.User.addTags({
        'role': user.role.name,
        'username': user.username,
      });
      await OneSignal.User.pushSubscription.optIn();
      await _registerCurrentOneSignalSubscription();
    } catch (error, stackTrace) {
      debugPrint('OneSignal user identification failed: $error');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<void> clearPushUser() async {
    _pushUser = null;
    _pushDio = null;
    _lastRegisteredSubscriptionId = null;

    if (!isRemotePushConfigured || !_remoteInitialized) return;

    try {
      await OneSignal.User.pushSubscription.optOut();
      await OneSignal.logout();
    } catch (error) {
      debugPrint('OneSignal logout failed: $error');
    }
  }

  Future<void> registerPushToken({
    required Dio dio,
    required String deviceToken,
    String provider = 'onesignal',
  }) async {
    if (deviceToken.trim().isEmpty) return;
    await dio.post<Map<String, dynamic>>(
      '/push-subscriptions',
      data: {
        'provider': provider,
        'deviceToken': deviceToken.trim(),
        'platform': Platform.isIOS ? 'ios' : 'android',
      },
    );
  }

  Future<void> _initOneSignalIfConfigured() async {
    if (_remoteInitialized || !isRemotePushConfigured) return;

    try {
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      }

      await OneSignal.initialize(_oneSignalAppId.trim());
      OneSignal.Notifications.addClickListener((event) {
        debugPrint(
          'OneSignal notification tapped: '
          '${event.notification.additionalData ?? event.notification.title}',
        );
      });
      await OneSignal.Notifications.requestPermission(false);
      _attachPushSubscriptionObserver();
      _remoteInitialized = true;
    } catch (error, stackTrace) {
      debugPrint('OneSignal initialization failed: $error');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  void _attachPushSubscriptionObserver() {
    if (_pushObserverAttached) return;
    OneSignal.User.pushSubscription.addObserver((stateChanges) {
      _registerCurrentOneSignalSubscription(
        subscriptionId: stateChanges.current.id,
      );
    });
    _pushObserverAttached = true;
  }

  Future<void> _registerCurrentOneSignalSubscription({
    String? subscriptionId,
  }) async {
    final dio = _pushDio;
    final user = _pushUser;
    final id = subscriptionId ?? OneSignal.User.pushSubscription.id;

    if (dio == null || user == null || id == null || id.trim().isEmpty) {
      return;
    }
    if (_registeringPushToken || _lastRegisteredSubscriptionId == id) {
      return;
    }

    _registeringPushToken = true;
    try {
      await registerPushToken(dio: dio, deviceToken: id);
      _lastRegisteredSubscriptionId = id;
      debugPrint('Registered OneSignal subscription for ${user.role.name}.');
    } catch (error, stackTrace) {
      debugPrint('Registering OneSignal subscription failed: $error');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
    } finally {
      _registeringPushToken = false;
    }
  }

  Future<void> sendEmailNotification({
    required String email,
    required String subject,
    required String body,
  }) async {
    debugPrint('Email notification queued for $email: $subject');
  }

  Future<void> sendSmsNotification({
    required String phoneNumber,
    required String message,
  }) async {
    debugPrint('SMS notification queued for $phoneNumber: $message');
  }
}
