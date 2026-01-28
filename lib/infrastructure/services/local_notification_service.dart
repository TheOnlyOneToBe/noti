import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final localNotificationServiceProvider = Provider((ref) => LocalNotificationService());

/// Handler global pour les notifications en background
/// Doit être une fonction top-level ou static
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
}

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String?> _onNotificationClick = StreamController<String?>.broadcast();
  Stream<String?> get onNotificationClick => _onNotificationClick.stream;

  bool _isInitialized = false;
  String? _pendingPayload;

  /// Initialise le service de notification et configure les fuseaux horaires
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialiser la base de données des fuseaux horaires
      await _configureLocalTimeZone();

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
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Récupération du payload si l'app a été lancée via notif
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      
      if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
        _pendingPayload = notificationAppLaunchDetails!.notificationResponse?.payload;
      }

      // Création du channel Android
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      const AndroidNotificationChannel examChannel = AndroidNotificationChannel(
        'exam_channel',
        'Exam Notifications',
        description: 'Notifications for exam reminders',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(examChannel);
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }

      _isInitialized = true;
      debugPrint('LocalNotificationService: Initialized successfully');
    } catch (e) {
      debugPrint('LocalNotificationService: Error initializing: $e');
    }
  }

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('LocalNotificationService: Error setting local location: $e');
      // Fallback si nécessaire
      try {
        tz.setLocalLocation(tz.local);
      } catch (e) {
        // Ignorer si déjà défini ou erreur
      }
    }
  }

  void checkPendingNotification() {
    if (_pendingPayload != null) {
      _onNotificationClick.add(_pendingPayload);
      _pendingPayload = null;
    }
  }

  void dispose() {
    _onNotificationClick.close();
  }

  /// Planifie une notification à une date précise
  /// [scheduledDate] doit être une date future. Si elle est passée, la méthode l'ignore ou log.
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      debugPrint('LocalNotificationService: Ignored scheduling for past date: $scheduledDate');
      return;
    }

    try {
      // Conversion sécurisée vers TZDateTime
      final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
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
      debugPrint('LocalNotificationService: Scheduled [$id] at $tzDate');
    } catch (e) {
      debugPrint('LocalNotificationService: Error scheduling notification [$id]: $e');
    }
  }

  Future<void> cancel(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      debugPrint('LocalNotificationService: Cancelled [$id]');
    } catch (e) {
      debugPrint('LocalNotificationService: Error cancelling [$id]: $e');
    }
  }

  /// Annule une liste d'IDs
  Future<void> cancelMultiple(List<int> ids) async {
    for (final id in ids) {
      await cancel(id);
    }
  }

  /// Annule tout (à utiliser avec précaution)
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
