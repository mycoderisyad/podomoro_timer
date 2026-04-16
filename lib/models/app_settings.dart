import '../core/constants/app_constants.dart';

class AppSettings {
  int focusDuration;
  int breakDuration;
  bool autoStartBreak;
  int modeTransitionDelaySeconds;
  bool syncMusicWithTimer;
  double defaultVolume;

  bool soundEnabled;
  String notificationSound;
  double notificationVolume;

  String autoClearSchedule;
  String languageCode;

  AppSettings({
    this.focusDuration = AppConstants.defaultFocusDuration,
    this.breakDuration = AppConstants.defaultBreakDuration,
    this.autoStartBreak = false,
    this.modeTransitionDelaySeconds =
        AppConstants.defaultModeTransitionDelaySeconds,
    this.syncMusicWithTimer = true,
    this.defaultVolume = AppConstants.defaultVolume,
    this.soundEnabled = true,
    this.notificationSound = 'assets/audio/notifications/bell.ogg',
    this.notificationVolume = 1.0,
    this.autoClearSchedule = 'never',
    this.languageCode = 'en',
  });

  AppSettings copyWith({
    int? focusDuration,
    int? breakDuration,
    bool? autoStartBreak,
    int? modeTransitionDelaySeconds,
    bool? syncMusicWithTimer,
    double? defaultVolume,
    bool? soundEnabled,
    String? notificationSound,
    double? notificationVolume,
    String? autoClearSchedule,
    String? languageCode,
  }) {
    return AppSettings(
      focusDuration: focusDuration ?? this.focusDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      autoStartBreak: autoStartBreak ?? this.autoStartBreak,
      modeTransitionDelaySeconds:
          modeTransitionDelaySeconds ?? this.modeTransitionDelaySeconds,
      syncMusicWithTimer: syncMusicWithTimer ?? this.syncMusicWithTimer,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationSound: notificationSound ?? this.notificationSound,
      notificationVolume: notificationVolume ?? this.notificationVolume,
      autoClearSchedule: autoClearSchedule ?? this.autoClearSchedule,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
