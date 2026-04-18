import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract interface class BackgroundStatusNotifier {
  Future<void> initialize();

  Future<void> show({required String title, required String body});

  Future<void> cancel();
}

class LocalNotificationsBackgroundStatusNotifier
    implements BackgroundStatusNotifier {
  static const String _channelId = 'pomodoro_background_status';
  static const String _channelName = 'Pomodoro Background Status';
  static const String _channelDescription =
      'Shows the active timer and music while the app is in the background.';
  static const int _notificationId = 1201;

  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  bool _isInitialized = false;

  LocalNotificationsBackgroundStatusNotifier({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
           notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
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

  @override
  Future<void> show({required String title, required String body}) async {
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

  @override
  Future<void> cancel() async {
    if (!_isInitialized || kIsWeb) {
      return;
    }

    await _notificationsPlugin.cancel(_notificationId);
  }
}
