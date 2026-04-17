import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BackgroundStatusNotificationService {
  BackgroundStatusNotificationService._();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'pomodoro_background_status';
  static const String _channelName = 'Pomodoro Background Status';
  static const String _channelDescription =
      'Shows the active timer and music while the app is in the background.';
  static const int _notificationId = 1201;

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized || kIsWeb) {
      return;
    }

    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.low,
        playSound: false,
      ),
    );
    await androidPlugin?.requestNotificationsPermission();

    _isInitialized = true;
  }

  static Future<void> show({
    required String title,
    required String body,
  }) async {
    if (!_isInitialized || kIsWeb) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
      playSound: false,
      enableVibration: false,
      showWhen: false,
    );

    await _notificationsPlugin.show(
      _notificationId,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> cancel() async {
    if (!_isInitialized || kIsWeb) {
      return;
    }

    await _notificationsPlugin.cancel(_notificationId);
  }
}
