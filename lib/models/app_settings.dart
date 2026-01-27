import '../core/constants/app_constants.dart';

class AppSettings {
  int focusDuration;
  int breakDuration;
  bool autoStartBreak;
  bool syncMusicWithTimer;
  double defaultVolume;

  AppSettings({
    this.focusDuration = AppConstants.defaultFocusDuration,
    this.breakDuration = AppConstants.defaultBreakDuration,
    this.autoStartBreak = false,
    this.syncMusicWithTimer = true,
    this.defaultVolume = AppConstants.defaultVolume,
  });

  AppSettings copyWith({
    int? focusDuration,
    int? breakDuration,
    bool? autoStartBreak,
    bool? syncMusicWithTimer,
    double? defaultVolume,
  }) {
    return AppSettings(
      focusDuration: focusDuration ?? this.focusDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      autoStartBreak: autoStartBreak ?? this.autoStartBreak,
      syncMusicWithTimer: syncMusicWithTimer ?? this.syncMusicWithTimer,
      defaultVolume: defaultVolume ?? this.defaultVolume,
    );
  }
}
