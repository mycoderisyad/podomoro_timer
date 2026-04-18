import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:podomoro_timer/shared/services/notification_audio_service.dart';
import 'package:podomoro_timer/shared/settings/app_settings.dart';

class SettingsFormController extends ChangeNotifier {
  static const List<Map<String, String>> soundOptions = [
    {'id': 'bell', 'path': 'assets/audio/notifications/bell.ogg'},
    {'id': 'chime', 'path': 'assets/audio/notifications/chime.ogg'},
    {'id': 'ding', 'path': 'assets/audio/notifications/ding.ogg'},
  ];
  static const List<String> autoClearOptions = [
    'never',
    '7_days',
    '30_days',
    '3_months',
    '1_year',
  ];
  static const List<String> languageOptions = ['en', 'id'];

  final NotificationAudioService _notificationAudioService;
  final AppSettings initialSettings;

  bool _autoStartBreak;
  int _modeTransitionDelaySeconds;
  bool _syncMusicWithTimer;
  double _defaultVolume;
  bool _soundEnabled;
  String _notificationSound;
  double _notificationVolume;
  String _autoClearSchedule;
  String _languageCode;

  SettingsFormController({
    required this.initialSettings,
    required NotificationAudioService notificationAudioService,
  }) : _notificationAudioService = notificationAudioService,
       _autoStartBreak = initialSettings.autoStartBreak,
       _modeTransitionDelaySeconds = initialSettings.modeTransitionDelaySeconds,
       _syncMusicWithTimer = initialSettings.syncMusicWithTimer,
       _defaultVolume = initialSettings.defaultVolume,
       _soundEnabled = initialSettings.soundEnabled,
       _notificationSound = initialSettings.notificationSound,
       _notificationVolume = initialSettings.notificationVolume,
       _autoClearSchedule = initialSettings.autoClearSchedule,
       _languageCode = initialSettings.languageCode;

  bool get autoStartBreak => _autoStartBreak;
  int get modeTransitionDelaySeconds => _modeTransitionDelaySeconds;
  bool get syncMusicWithTimer => _syncMusicWithTimer;
  double get defaultVolume => _defaultVolume;
  bool get soundEnabled => _soundEnabled;
  String get notificationSound => _notificationSound;
  double get notificationVolume => _notificationVolume;
  String get autoClearSchedule => _autoClearSchedule;
  String get languageCode => _languageCode;

  bool get hasUnsavedChanges {
    return _autoStartBreak != initialSettings.autoStartBreak ||
        _modeTransitionDelaySeconds !=
            initialSettings.modeTransitionDelaySeconds ||
        _syncMusicWithTimer != initialSettings.syncMusicWithTimer ||
        _defaultVolume != initialSettings.defaultVolume ||
        _soundEnabled != initialSettings.soundEnabled ||
        _notificationSound != initialSettings.notificationSound ||
        _notificationVolume != initialSettings.notificationVolume ||
        _autoClearSchedule != initialSettings.autoClearSchedule ||
        _languageCode != initialSettings.languageCode;
  }

  AppSettings buildUpdatedSettings() {
    return initialSettings.copyWith(
      autoStartBreak: _autoStartBreak,
      modeTransitionDelaySeconds: _modeTransitionDelaySeconds,
      syncMusicWithTimer: _syncMusicWithTimer,
      defaultVolume: _defaultVolume,
      soundEnabled: _soundEnabled,
      notificationSound: _notificationSound,
      notificationVolume: _notificationVolume,
      autoClearSchedule: _autoClearSchedule,
      languageCode: _languageCode,
    );
  }

  Future<bool> playSoundPreview() async {
    try {
      await _notificationAudioService.playAsset(
        assetPath: _notificationSound,
        volume: _notificationVolume,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  void setAutoStartBreak(bool value) {
    if (_autoStartBreak == value) {
      return;
    }
    _autoStartBreak = value;
    notifyListeners();
  }

  void setModeTransitionDelaySeconds(int value) {
    if (_modeTransitionDelaySeconds == value) {
      return;
    }
    _modeTransitionDelaySeconds = value;
    notifyListeners();
  }

  void setSyncMusicWithTimer(bool value) {
    if (_syncMusicWithTimer == value) {
      return;
    }
    _syncMusicWithTimer = value;
    notifyListeners();
  }

  void setDefaultVolume(double value) {
    if (_defaultVolume == value) {
      return;
    }
    _defaultVolume = value;
    notifyListeners();
  }

  void setSoundEnabled(bool value) {
    if (_soundEnabled == value) {
      return;
    }
    _soundEnabled = value;
    notifyListeners();
  }

  void setNotificationSound(String value) {
    if (_notificationSound == value) {
      return;
    }
    _notificationSound = value;
    notifyListeners();
  }

  void setNotificationVolume(double value) {
    if (_notificationVolume == value) {
      return;
    }
    _notificationVolume = value;
    notifyListeners();
  }

  void setAutoClearSchedule(String value) {
    if (_autoClearSchedule == value) {
      return;
    }
    _autoClearSchedule = value;
    notifyListeners();
  }

  void setLanguageCode(String value) {
    if (_languageCode == value) {
      return;
    }
    _languageCode = value;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_notificationAudioService.dispose());
    super.dispose();
  }
}
