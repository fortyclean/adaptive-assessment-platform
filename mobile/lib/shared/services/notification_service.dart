import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// يدير الإشعارات المحلية ويجهز التطبيق للتوسع لاحقا عبر API.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  static const AndroidNotificationDetails _instantAndroidDetails =
      AndroidNotificationDetails(
    'default_channel',
    'التنبيهات',
    channelDescription: 'تنبيهات لحظية للأداء والتقارير',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  static const AndroidNotificationDetails _scheduledAndroidDetails =
      AndroidNotificationDetails(
    'scheduled_channel',
    'تنبيهات مجدولة',
    channelDescription: 'تنبيهات مجدولة للتقارير أو الأحداث',
    importance: Importance.high,
    priority: Priority.high,
  );

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

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
