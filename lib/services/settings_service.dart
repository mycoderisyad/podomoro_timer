import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../core/constants/app_constants.dart';

class SettingsService {
  static const String _keyFocusDuration = 'setting_focus_duration';
  static const String _keyBreakDuration = 'setting_break_duration';
  static const String _keyAutoStartBreak = 'setting_auto_start_break';
  static const String _keyModeTransitionDelaySeconds =
      'setting_mode_transition_delay_seconds';
  static const String _keySyncMusicWithTimer = 'setting_sync_music';
  static const String _keyDefaultVolume = 'setting_default_volume';
  static const String _keySoundEnabled = 'setting_sound_enabled';
  static const String _keyNotificationSound = 'setting_notification_sound';
  static const String _keyNotificationVolume = 'setting_notification_volume';
  static const String _keyAutoClearSchedule = 'setting_auto_clear_schedule';
  static const String _keyLanguageCode = 'setting_language_code';
  static const String _legacyFocusLockEnabledKey = 'setting_focus_lock_enabled';

  static String _normalizeNotificationSoundPath(String? path) {
    switch (path) {
      case 'assets/audio/bell.ogg':
        return 'assets/audio/notifications/bell.ogg';
      case 'assets/audio/chime.ogg':
        return 'assets/audio/notifications/chime.ogg';
      case 'assets/audio/ding.ogg':
        return 'assets/audio/notifications/ding.ogg';
      case null:
      case '':
        return 'assets/audio/notifications/bell.ogg';
      default:
        return path;
    }
  }

  static String _normalizeLanguageCode(String? code) {
    switch (code) {
      case 'id':
        return 'id';
      case 'en':
      case null:
      case '':
        return 'en';
      default:
        return 'en';
    }
  }

  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyFocusLockEnabledKey);
    final notificationSound = _normalizeNotificationSoundPath(
      prefs.getString(_keyNotificationSound),
    );

    return AppSettings(
      focusDuration:
          prefs.getInt(_keyFocusDuration) ?? AppConstants.defaultFocusDuration,
      breakDuration:
          prefs.getInt(_keyBreakDuration) ?? AppConstants.defaultBreakDuration,
      autoStartBreak: prefs.getBool(_keyAutoStartBreak) ?? false,
      modeTransitionDelaySeconds:
          prefs.getInt(_keyModeTransitionDelaySeconds) ??
          AppConstants.defaultModeTransitionDelaySeconds,
      syncMusicWithTimer: prefs.getBool(_keySyncMusicWithTimer) ?? true,
      defaultVolume:
          prefs.getDouble(_keyDefaultVolume) ?? AppConstants.defaultVolume,
      soundEnabled: prefs.getBool(_keySoundEnabled) ?? true,
      notificationSound: notificationSound,
      notificationVolume: prefs.getDouble(_keyNotificationVolume) ?? 1.0,
      autoClearSchedule: prefs.getString(_keyAutoClearSchedule) ?? 'never',
      languageCode: _normalizeLanguageCode(prefs.getString(_keyLanguageCode)),
    );
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_keyFocusDuration, settings.focusDuration);
    await prefs.setInt(_keyBreakDuration, settings.breakDuration);
    await prefs.setBool(_keyAutoStartBreak, settings.autoStartBreak);
    await prefs.setInt(
      _keyModeTransitionDelaySeconds,
      settings.modeTransitionDelaySeconds,
    );
    await prefs.setBool(_keySyncMusicWithTimer, settings.syncMusicWithTimer);
    await prefs.setDouble(_keyDefaultVolume, settings.defaultVolume);
    await prefs.setBool(_keySoundEnabled, settings.soundEnabled);
    await prefs.setString(
      _keyNotificationSound,
      _normalizeNotificationSoundPath(settings.notificationSound),
    );
    await prefs.setDouble(_keyNotificationVolume, settings.notificationVolume);
    await prefs.setString(_keyAutoClearSchedule, settings.autoClearSchedule);
    await prefs.setString(
      _keyLanguageCode,
      _normalizeLanguageCode(settings.languageCode),
    );
    await prefs.remove(_legacyFocusLockEnabledKey);
  }
}
