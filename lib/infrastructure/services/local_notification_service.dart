import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final localNotificationServiceProvider = Provider((ref) => LocalNotificationService());

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String?> _onNotificationClick = StreamController<String?>.broadcast();
  Stream<String?> get onNotificationClick => _onNotificationClick.stream;

  bool _isInitialized = false;
  String? _pendingPayload;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezones for scheduled notifications
    tz.initializeTimeZones();

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _onNotificationClick.add(response.payload);
        },
      );

      // Handle app launch from notification
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      
      if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
        _pendingPayload = notificationAppLaunchDetails!.notificationResponse?.payload;
      }

      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Channel for Exams
      const AndroidNotificationChannel examChannel = AndroidNotificationChannel(
        'exam_channel',
        'Exam Notifications',
        description: 'Notifications for exam reminders',
        importance: Importance.max,
      );

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(examChannel);
        
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
        
        debugPrint('LocalNotificationService: Permission granted: $granted');
      }

      _isInitialized = true;
      debugPrint('LocalNotificationService: Initialized successfully');
    } catch (e) {
      debugPrint('LocalNotificationService: Error initializing: $e');
    }
  }

  /// Checks if the app was launched by a notification and emits the payload if so.
  /// Should be called after the UI is ready to handle navigation.
  void checkPendingNotification() {
    if (_pendingPayload != null) {
      debugPrint('LocalNotificationService: Handling pending notification payload');
      _onNotificationClick.add(_pendingPayload);
      _pendingPayload = null;
    }
  }

  void dispose() {
    _onNotificationClick.close();
  }

  Future<void> showExamNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      debugPrint('LocalNotificationService: Not initialized, initializing now...');
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'exam_channel',
        'Exam Notifications',
        channelDescription: 'Notifications for exam reminders',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      debugPrint('LocalNotificationService: Showing notification [$id]: $title - $body');

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
      debugPrint('LocalNotificationService: Notification shown successfully');
    } catch (e) {
      debugPrint('LocalNotificationService: Error showing notification: $e');
    }
  }

  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'noti_channel',
        'Test Notifications',
        channelDescription: 'Channel for test notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notificationsPlugin.show(
        0,
        'Test Notification',
        'This is a test notification from noti',
        platformChannelSpecifics,
        payload: jsonEncode({'type': 'test'}),
      );
    } catch (e) {
      debugPrint('Error showing test notification: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'exam_channel',
          'Exam Notifications',
          channelDescription: 'Notifications for exam reminders',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
          presentAlert: true,
          presentBanner: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
  
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
