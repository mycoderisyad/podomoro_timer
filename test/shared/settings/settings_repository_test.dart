import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:podomoro_timer/shared/settings/app_settings.dart';
import 'package:podomoro_timer/shared/settings/settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesSettingsRepository', () {
    const repository = SharedPreferencesSettingsRepository();

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loads default settings when storage is empty', () async {
      final settings = await repository.loadSettings();

      expect(settings.focusDuration, 1500);
      expect(settings.breakDuration, 300);
      expect(settings.languageCode, 'en');
      expect(settings.notificationSound, 'assets/audio/notifications/bell.ogg');
    });

    test('normalizes legacy notification sound and invalid language', () async {
      SharedPreferences.setMockInitialValues({
        'setting_notification_sound': 'assets/audio/bell.ogg',
        'setting_language_code': 'jp',
      });

      final settings = await repository.loadSettings();

      expect(settings.notificationSound, 'assets/audio/notifications/bell.ogg');
      expect(settings.languageCode, 'en');
    });

    test('saves and reloads updated settings', () async {
      const expected = AppSettings(
        focusDuration: 1800,
        breakDuration: 420,
        autoStartBreak: true,
        modeTransitionDelaySeconds: 5,
        syncMusicWithTimer: false,
        defaultVolume: 0.8,
        soundEnabled: false,
        notificationSound: 'assets/audio/notifications/ding.ogg',
        notificationVolume: 0.3,
        autoClearSchedule: '30_days',
        languageCode: 'id',
      );

      await repository.saveSettings(expected);
      final loaded = await repository.loadSettings();

      expect(loaded.focusDuration, expected.focusDuration);
      expect(loaded.breakDuration, expected.breakDuration);
      expect(loaded.autoStartBreak, expected.autoStartBreak);
      expect(
        loaded.modeTransitionDelaySeconds,
        expected.modeTransitionDelaySeconds,
      );
      expect(loaded.syncMusicWithTimer, expected.syncMusicWithTimer);
      expect(loaded.defaultVolume, expected.defaultVolume);
      expect(loaded.soundEnabled, expected.soundEnabled);
      expect(loaded.notificationSound, expected.notificationSound);
      expect(loaded.notificationVolume, expected.notificationVolume);
      expect(loaded.autoClearSchedule, expected.autoClearSchedule);
      expect(loaded.languageCode, expected.languageCode);
    });
  });
}
