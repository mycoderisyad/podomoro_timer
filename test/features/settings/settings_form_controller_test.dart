import 'package:flutter_test/flutter_test.dart';

import 'package:podomoro_timer/features/settings/application/settings_form_controller.dart';
import 'package:podomoro_timer/shared/services/notification_audio_service.dart';
import 'package:podomoro_timer/shared/settings/app_settings.dart';

void main() {
  group('SettingsFormController', () {
    test('tracks unsaved changes and builds updated settings', () {
      final controller = SettingsFormController(
        initialSettings: const AppSettings(),
        notificationAudioService: _FakeNotificationAudioService(),
      );

      expect(controller.hasUnsavedChanges, isFalse);

      controller.setLanguageCode('id');
      controller.setAutoStartBreak(true);
      controller.setNotificationVolume(0.4);

      final updated = controller.buildUpdatedSettings();

      expect(controller.hasUnsavedChanges, isTrue);
      expect(updated.languageCode, 'id');
      expect(updated.autoStartBreak, isTrue);
      expect(updated.notificationVolume, 0.4);
    });

    test('playSoundPreview delegates to notification audio service', () async {
      final fakeAudioService = _FakeNotificationAudioService();
      final controller = SettingsFormController(
        initialSettings: const AppSettings(),
        notificationAudioService: fakeAudioService,
      );

      final didPlay = await controller.playSoundPreview();

      expect(didPlay, isTrue);
      expect(fakeAudioService.playCount, 1);
    });
  });
}

class _FakeNotificationAudioService implements NotificationAudioService {
  int playCount = 0;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset({
    required String assetPath,
    required double volume,
  }) async {
    playCount++;
  }
}
