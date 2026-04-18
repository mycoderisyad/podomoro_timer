import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:podomoro_timer/features/music/application/music_playback_controller.dart';
import 'package:podomoro_timer/features/music/domain/music_track.dart';
import 'package:podomoro_timer/features/timer/application/timer_controller.dart';
import 'package:podomoro_timer/features/timer/application/timer_ui_event.dart';
import 'package:podomoro_timer/features/timer/domain/timer_mode.dart';
import 'package:podomoro_timer/l10n/app_localizations.dart';
import 'package:podomoro_timer/shared/services/background_status_notifier.dart';
import 'package:podomoro_timer/shared/services/notification_audio_service.dart';
import 'package:podomoro_timer/shared/settings/app_settings.dart';
import 'package:podomoro_timer/shared/settings/settings_repository.dart';
import 'package:podomoro_timer/shared/statistics/focus_session_record.dart';
import 'package:podomoro_timer/shared/statistics/statistic_record.dart';
import 'package:podomoro_timer/shared/statistics/statistics_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimerController', () {
    test('updates duration and persists settings', () async {
      final settingsRepository = _FakeSettingsRepository();
      final controller = TimerController(
        initialSettings: const AppSettings(),
        settingsRepository: settingsRepository,
        statisticsRepository: _FakeStatisticsRepository(),
        notificationAudioService: _FakeNotificationAudioService(),
        backgroundStatusNotifier: _FakeBackgroundStatusNotifier(),
        musicPlaybackController: _FakeMusicPlaybackHandle(),
      );

      await controller.updateCurrentDuration(
        durationSeconds: 2100,
        sessionName: 'Deep Work',
      );

      expect(controller.settings.focusDuration, 2100);
      expect(controller.secondsRemaining, 2100);
      expect(controller.nextFocusSessionNameOverride, 'Deep Work');
      expect(settingsRepository.savedSettings?.focusDuration, 2100);
    });

    test('completes a focus timer and records statistics', () async {
      final statisticsRepository = _FakeStatisticsRepository();
      final controller = TimerController(
        initialSettings: const AppSettings(
          focusDuration: 1,
          breakDuration: 1,
          modeTransitionDelaySeconds: 0,
        ),
        settingsRepository: _FakeSettingsRepository(),
        statisticsRepository: statisticsRepository,
        notificationAudioService: _FakeNotificationAudioService(),
        backgroundStatusNotifier: _FakeBackgroundStatusNotifier(),
        musicPlaybackController: _FakeMusicPlaybackHandle(),
        now: () => DateTime(2026, 4, 18, 8),
      );

      controller.bindLocalizations(AppLocalizations(const Locale('en')));
      await controller.initialize();

      final eventFuture = controller.events.first;
      controller.startTimer();

      final event = await eventFuture.timeout(const Duration(seconds: 3));

      expect(event.type, TimerUiEventType.focusSessionCompleted);
      expect(controller.currentMode, TimerMode.break_);
      expect(statisticsRepository.addCallCount, 1);
      expect(statisticsRepository.lastFocusSession?.displayName, 'Session #1');
      expect(statisticsRepository.lastFocusSeconds, 1);
    });
  });
}

class _FakeSettingsRepository implements SettingsRepository {
  AppSettings? savedSettings;

  @override
  Future<AppSettings> loadSettings() async =>
      savedSettings ?? const AppSettings();

  @override
  Future<void> saveSettings(AppSettings settings) async {
    savedSettings = settings;
  }
}

class _FakeStatisticsRepository implements StatisticsRepository {
  int addCallCount = 0;
  int lastFocusSeconds = 0;
  FocusSessionRecord? lastFocusSession;

  @override
  Future<void> addOrUpdateToday({
    int focusSeconds = 0,
    int breakSeconds = 0,
    int completedSessions = 0,
    FocusSessionRecord? focusSession,
  }) async {
    addCallCount++;
    lastFocusSeconds = focusSeconds;
    lastFocusSession = focusSession;
  }

  @override
  Future<void> clearAllRecords() async {}

  @override
  List<StatisticRecord> filterByRange(
    List<StatisticRecord> records,
    DateTime start,
    DateTime end,
  ) {
    return records;
  }

  @override
  Future<List<StatisticRecord>> loadRecords() async => const [];

  @override
  Future<void> runAutoClearIfNeeded(String schedule) async {}

  @override
  Future<void> saveRecords(List<StatisticRecord> records) async {}
}

class _FakeNotificationAudioService implements NotificationAudioService {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset({
    required String assetPath,
    required double volume,
  }) async {}
}

class _FakeBackgroundStatusNotifier implements BackgroundStatusNotifier {
  @override
  Future<void> cancel() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> show({required String title, required String body}) async {}
}

class _FakeMusicPlaybackHandle extends ChangeNotifier
    implements MusicPlaybackHandle {
  @override
  int get currentQueueIndex => 0;

  @override
  MusicTrack? get currentTrack => null;

  @override
  bool get isMusicPlaying => false;

  @override
  List<MusicTrack> get musicQueue => const [];

  @override
  Duration get playbackPosition => Duration.zero;

  @override
  Duration get trackDuration => Duration.zero;

  @override
  Future<void> initialize(double initialVolume) async {}

  @override
  Future<void> jumpToTrack(int index, {required bool autoplay}) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> playNext({required bool autoplay}) async {}

  @override
  Future<void> playOrResume() async {}

  @override
  Future<void> playPrevious({required bool autoplay}) async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> setQueue(List<MusicTrack> queue) async {}

  @override
  Future<void> setVolume(double value) async {}

  @override
  Future<void> syncPlayback() async {}
}
