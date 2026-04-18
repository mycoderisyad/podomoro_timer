import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:podomoro_timer/features/music/application/music_playback_controller.dart';
import 'package:podomoro_timer/features/music/domain/music_track.dart';
import 'package:podomoro_timer/features/timer/application/timer_ui_event.dart';
import 'package:podomoro_timer/features/timer/application/timer_view_state.dart';
import 'package:podomoro_timer/features/timer/domain/timer_mode.dart';
import 'package:podomoro_timer/l10n/app_localizations.dart';
import 'package:podomoro_timer/shared/services/background_status_notifier.dart';
import 'package:podomoro_timer/shared/services/notification_audio_service.dart';
import 'package:podomoro_timer/shared/settings/app_settings.dart';
import 'package:podomoro_timer/shared/settings/settings_repository.dart';
import 'package:podomoro_timer/shared/statistics/focus_session_record.dart';
import 'package:podomoro_timer/shared/statistics/statistics_repository.dart';

class TimerController extends ChangeNotifier {
  static const List<int> focusDurationOptions = [
    900,
    1200,
    1500,
    1800,
    2100,
    2700,
    3000,
  ];
  static const List<int> breakDurationOptions = [180, 300, 420, 600, 900];

  final SettingsRepository _settingsRepository;
  final StatisticsRepository _statisticsRepository;
  final NotificationAudioService _notificationAudioService;
  final BackgroundStatusNotifier _backgroundStatusNotifier;
  final DateTime Function() _now;
  final StreamController<TimerUiEvent> _eventsController =
      StreamController<TimerUiEvent>.broadcast();

  late final MusicPlaybackHandle _musicPlaybackController;
  Timer? _timer;
  Timer? _modeTransitionTimer;
  AppLocalizations? _l10n;
  bool _isAppInBackground = false;
  TimerViewState _state;

  TimerController({
    required AppSettings initialSettings,
    required SettingsRepository settingsRepository,
    required StatisticsRepository statisticsRepository,
    required NotificationAudioService notificationAudioService,
    required BackgroundStatusNotifier backgroundStatusNotifier,
    MusicPlaybackHandle? musicPlaybackController,
    DateTime Function()? now,
  }) : _settingsRepository = settingsRepository,
       _statisticsRepository = statisticsRepository,
       _notificationAudioService = notificationAudioService,
       _backgroundStatusNotifier = backgroundStatusNotifier,
       _now = now ?? DateTime.now,
       _state = TimerViewState.initial(
         settings: initialSettings,
         now: (now ?? DateTime.now)(),
       ) {
    _musicPlaybackController =
        musicPlaybackController ??
        MusicPlaybackController(shouldAutoPlay: () => shouldSyncMusicToTimer);
    _musicPlaybackController.addListener(_handleMusicPlaybackChanged);
  }

  Stream<TimerUiEvent> get events => _eventsController.stream;
  TimerViewState get state => _state;

  AppSettings get settings => _state.settings;
  TimerMode get currentMode => _state.currentMode;
  bool get isRunning => _state.isRunning;
  bool get isTransitioningMode => _state.isTransitioningMode;
  int get secondsRemaining => _state.secondsRemaining;
  int get focusDuration => _state.settings.focusDuration;
  int get breakDuration => _state.settings.breakDuration;
  String? get nextFocusSessionNameOverride =>
      _state.nextFocusSessionNameOverride;

  List<MusicTrack> get musicQueue => _musicPlaybackController.musicQueue;
  int get currentQueueIndex => _musicPlaybackController.currentQueueIndex;
  bool get isMusicPlaying => _musicPlaybackController.isMusicPlaying;
  Duration get playbackPosition => _musicPlaybackController.playbackPosition;
  Duration get trackDuration => _musicPlaybackController.trackDuration;
  MusicTrack? get currentTrack => _musicPlaybackController.currentTrack;

  bool get shouldSyncMusicToTimer =>
      _state.settings.syncMusicWithTimer &&
      _state.isRunning &&
      _musicPlaybackController.musicQueue.isNotEmpty;

  String get sessionChipLabel {
    if (_state.pendingMode == TimerMode.break_ &&
        _state.lastCompletedFocusSessionLabel != null &&
        _state.lastCompletedFocusSessionLabel!.isNotEmpty) {
      return _state.lastCompletedFocusSessionLabel!;
    }

    if (_state.currentMode.isFocus) {
      return _plannedFocusSessionLabelForState(_state);
    }

    if (_state.lastCompletedFocusSessionLabel != null &&
        _state.lastCompletedFocusSessionLabel!.isNotEmpty) {
      return _state.lastCompletedFocusSessionLabel!;
    }

    final index = _state.completedSessions == 0 ? 1 : _state.completedSessions;
    return _sessionCountLabel(index);
  }

  String? get transitionModeLabel {
    if (_state.pendingMode == null) {
      return null;
    }

    return _headingToModeLabel(_labelForMode(_state.pendingMode!));
  }

  String? get transitionStatusText {
    if (_state.pendingMode == null || _state.modeTransitionCountdown <= 0) {
      return null;
    }

    return _transitionStatusLabel(
      _labelForMode(_state.pendingMode!),
      _state.modeTransitionCountdown,
    );
  }

  Future<void> initialize() async {
    await _backgroundStatusNotifier.initialize();
    await _musicPlaybackController.initialize(_state.settings.defaultVolume);
    await _statisticsRepository.runAutoClearIfNeeded(
      _state.settings.autoClearSchedule,
    );
    await _applyMusicSyncState();
  }

  void bindLocalizations(AppLocalizations localizations) {
    _l10n = localizations;
    if (_isAppInBackground) {
      unawaited(_refreshBackgroundStatusNotification());
    }
  }

  Future<void> handleLifecycleChange(AppLifecycleState lifecycleState) async {
    switch (lifecycleState) {
      case AppLifecycleState.resumed:
        _isAppInBackground = false;
        await _backgroundStatusNotifier.cancel();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _isAppInBackground = true;
        await _refreshBackgroundStatusNotification();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        break;
    }
  }

  void startTimer() {
    if (_state.isTransitioningMode || (_timer?.isActive ?? false)) {
      return;
    }

    _setState(_state.copyWith(isRunning: true));
    unawaited(_applyMusicSyncState());

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final normalizedState = _normalizeRuntimeStats(_state);

      if (normalizedState.secondsRemaining > 0) {
        _setState(
          normalizedState.copyWith(
            secondsRemaining: normalizedState.secondsRemaining - 1,
            totalFocusSeconds:
                normalizedState.totalFocusSeconds +
                (normalizedState.currentMode.isFocus ? 1 : 0),
            totalBreakSeconds:
                normalizedState.totalBreakSeconds +
                (normalizedState.currentMode.isFocus ? 0 : 1),
          ),
        );
        if (_isAppInBackground) {
          unawaited(_refreshBackgroundStatusNotification());
        }
        return;
      }

      timer.cancel();
      _timer = null;
      _setState(_state.copyWith(isRunning: false));
      if (_isAppInBackground) {
        unawaited(_refreshBackgroundStatusNotification());
      }
      unawaited(_handleTimerCompleted());
    });

    if (_isAppInBackground) {
      unawaited(_refreshBackgroundStatusNotification());
    }
  }

  void pauseTimer() {
    if (_state.isTransitioningMode) {
      return;
    }

    _timer?.cancel();
    _timer = null;
    _setState(_state.copyWith(isRunning: false));
    unawaited(_applyMusicSyncState());
  }

  void resetTimer() {
    _cancelPendingModeTransition();
    _timer?.cancel();
    _timer = null;

    _setState(
      _state.copyWith(
        isRunning: false,
        secondsRemaining: _state.currentMode.isFocus
            ? _state.settings.focusDuration
            : _state.settings.breakDuration,
        nextFocusSessionNameOverride: _state.currentMode.isFocus
            ? null
            : _state.nextFocusSessionNameOverride,
      ),
    );
    unawaited(_applyMusicSyncState());
  }

  void switchMode() {
    _cancelPendingModeTransition();
    pauseTimer();

    final nextMode = _state.currentMode.toggled;
    _setState(
      _state.copyWith(
        currentMode: nextMode,
        secondsRemaining: nextMode.isFocus
            ? _state.settings.focusDuration
            : _state.settings.breakDuration,
        nextFocusSessionNameOverride: nextMode.isFocus
            ? null
            : _state.nextFocusSessionNameOverride,
      ),
    );
  }

  Future<void> updateCurrentDuration({
    required int durationSeconds,
    String? sessionName,
  }) async {
    final sanitizedSessionName = _sanitizeSessionName(sessionName);
    final updatedSettings = _state.currentMode.isFocus
        ? _state.settings.copyWith(focusDuration: durationSeconds)
        : _state.settings.copyWith(breakDuration: durationSeconds);

    _setState(
      _state.copyWith(
        settings: updatedSettings,
        secondsRemaining: durationSeconds,
        nextFocusSessionNameOverride: _state.currentMode.isFocus
            ? sanitizedSessionName
            : _state.nextFocusSessionNameOverride,
      ),
    );

    await _settingsRepository.saveSettings(updatedSettings);
    if (_isAppInBackground) {
      await _refreshBackgroundStatusNotification();
    }
  }

  Future<void> applySettings(AppSettings updatedSettings) async {
    _setState(_state.copyWith(settings: updatedSettings));
    await _musicPlaybackController.setVolume(updatedSettings.defaultVolume);
    await _settingsRepository.saveSettings(updatedSettings);
    await _applyMusicSyncState();
  }

  Future<void> replaceMusicQueue(List<MusicTrack> queue) async {
    await _musicPlaybackController.setQueue(queue);
    await _applyMusicSyncState();
  }

  Future<void> jumpToTrack(int index) {
    return _musicPlaybackController.jumpToTrack(
      index,
      autoplay: shouldSyncMusicToTimer,
    );
  }

  Future<void> playPreviousTrack() {
    return _musicPlaybackController.playPrevious(
      autoplay: shouldSyncMusicToTimer,
    );
  }

  Future<void> playNextTrack() {
    return _musicPlaybackController.playNext(autoplay: shouldSyncMusicToTimer);
  }

  Future<void> updateSyncMusic(bool enabled) async {
    final updatedSettings = _state.settings.copyWith(
      syncMusicWithTimer: enabled,
    );
    _setState(_state.copyWith(settings: updatedSettings));
    await _settingsRepository.saveSettings(updatedSettings);
    await _musicPlaybackController.syncPlayback();
    if (_isAppInBackground) {
      await _refreshBackgroundStatusNotification();
    }
  }

  Future<void> updateDefaultVolume(double value) async {
    final updatedSettings = _state.settings.copyWith(defaultVolume: value);
    _setState(_state.copyWith(settings: updatedSettings));
    await _musicPlaybackController.setVolume(value);
    await _settingsRepository.saveSettings(updatedSettings);
  }

  Future<void> seekTrack(Duration position) {
    return _musicPlaybackController.seek(position);
  }

  Future<void> _handleTimerCompleted() async {
    final normalizedState = _normalizeRuntimeStats(_state);
    _setState(normalizedState);
    await _applyMusicSyncState();
    await _playNotificationSound();

    if (normalizedState.currentMode.isFocus) {
      final completedAt = _now();
      final sessionLabel = _plannedFocusSessionLabelForState(normalizedState);
      final customName = _sanitizeSessionName(
        normalizedState.nextFocusSessionNameOverride,
      );

      _setState(
        normalizedState.copyWith(
          completedSessions: normalizedState.completedSessions + 1,
          lastCompletedFocusSessionLabel: sessionLabel,
          nextFocusSessionNameOverride: null,
          runtimeStatsDate: _dateOnly(completedAt),
        ),
      );

      await _statisticsRepository.addOrUpdateToday(
        focusSeconds: normalizedState.settings.focusDuration,
        completedSessions: 1,
        focusSession: FocusSessionRecord(
          displayName: sessionLabel,
          customCategoryName: customName,
          durationSeconds: normalizedState.settings.focusDuration,
          completedAt: completedAt,
        ),
      );

      _eventsController.add(
        const TimerUiEvent(TimerUiEventType.focusSessionCompleted),
      );
      _scheduleModeTransition(
        nextMode: TimerMode.break_,
        autoStartNextTimer: normalizedState.settings.autoStartBreak,
      );
      return;
    }

    await _statisticsRepository.addOrUpdateToday(
      breakSeconds: normalizedState.settings.breakDuration,
    );
    _eventsController.add(const TimerUiEvent(TimerUiEventType.breakCompleted));
    _scheduleModeTransition(
      nextMode: TimerMode.focus,
      autoStartNextTimer: false,
    );
  }

  Future<void> _playNotificationSound() async {
    if (!_state.settings.soundEnabled) {
      return;
    }

    try {
      await _notificationAudioService.playAsset(
        assetPath: _state.settings.notificationSound,
        volume: _state.settings.notificationVolume,
      );
    } catch (error) {
      debugPrint('Failed to play notification sound: $error');
    }
  }

  Future<void> _applyMusicSyncState() async {
    if (_musicPlaybackController.musicQueue.isEmpty) {
      if (_isAppInBackground) {
        await _refreshBackgroundStatusNotification();
      }
      return;
    }

    await _musicPlaybackController.syncPlayback();
    if (_isAppInBackground) {
      await _refreshBackgroundStatusNotification();
    }
  }

  void _scheduleModeTransition({
    required TimerMode nextMode,
    required bool autoStartNextTimer,
  }) {
    _cancelPendingModeTransition();

    final delaySeconds = _state.settings.modeTransitionDelaySeconds;
    if (delaySeconds <= 0) {
      _completeModeTransition(
        nextMode: nextMode,
        autoStartNextTimer: autoStartNextTimer,
      );
      return;
    }

    _setState(
      _state.copyWith(
        pendingMode: nextMode,
        shouldAutoStartPendingMode: autoStartNextTimer,
        modeTransitionCountdown: delaySeconds,
      ),
    );

    _modeTransitionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.modeTransitionCountdown <= 1) {
        timer.cancel();
        _modeTransitionTimer = null;
        _completeModeTransition(
          nextMode: nextMode,
          autoStartNextTimer: _state.shouldAutoStartPendingMode,
        );
        return;
      }

      _setState(
        _state.copyWith(
          modeTransitionCountdown: _state.modeTransitionCountdown - 1,
        ),
      );
      if (_isAppInBackground) {
        unawaited(_refreshBackgroundStatusNotification());
      }
    });

    if (_isAppInBackground) {
      unawaited(_refreshBackgroundStatusNotification());
    }
  }

  void _completeModeTransition({
    required TimerMode nextMode,
    required bool autoStartNextTimer,
  }) {
    _modeTransitionTimer?.cancel();
    _modeTransitionTimer = null;

    _setState(
      _state.copyWith(
        pendingMode: null,
        shouldAutoStartPendingMode: false,
        modeTransitionCountdown: 0,
        currentMode: nextMode,
        secondsRemaining: nextMode.isFocus
            ? _state.settings.focusDuration
            : _state.settings.breakDuration,
      ),
    );

    if (_isAppInBackground) {
      unawaited(_refreshBackgroundStatusNotification());
    }

    if (autoStartNextTimer) {
      startTimer();
    }
  }

  void _cancelPendingModeTransition() {
    _modeTransitionTimer?.cancel();
    _modeTransitionTimer = null;

    if (!_state.isTransitioningMode) {
      return;
    }

    _setState(
      _state.copyWith(
        pendingMode: null,
        shouldAutoStartPendingMode: false,
        modeTransitionCountdown: 0,
      ),
    );
  }

  TimerViewState _normalizeRuntimeStats(TimerViewState input) {
    final today = _dateOnly(_now());
    if (_isSameDay(input.runtimeStatsDate, today)) {
      return input;
    }

    return input.copyWith(
      completedSessions: 0,
      totalFocusSeconds: 0,
      totalBreakSeconds: 0,
      runtimeStatsDate: today,
    );
  }

  String _plannedFocusSessionLabelForState(TimerViewState timerState) {
    final customName = _sanitizeSessionName(
      timerState.nextFocusSessionNameOverride,
    );
    return customName ?? _sessionCountLabel(timerState.nextSessionNumber);
  }

  String _labelForMode(TimerMode mode) {
    if (mode.isFocus) {
      return _l10n?.focus ?? 'Focus';
    }
    return _l10n?.breakLabel ?? 'Break';
  }

  String _headingToModeLabel(String mode) {
    return _l10n?.headingToModeLabel(mode) ?? 'Heading to $mode';
  }

  String _transitionStatusLabel(String mode, int seconds) {
    return _l10n?.transitionStatusLabel(mode, seconds) ??
        'Switching to $mode in $seconds s';
  }

  String _sessionCountLabel(int count) {
    return _l10n?.sessionCount(count) ?? 'Session #$count';
  }

  String? _sanitizeSessionName(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  String _formatNotificationTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _refreshBackgroundStatusNotification() async {
    final l10n = _l10n;
    if (!_isAppInBackground || l10n == null) {
      return;
    }

    final shouldShowTrack =
        _state.settings.syncMusicWithTimer &&
        currentTrack != null &&
        _musicPlaybackController.musicQueue.isNotEmpty;

    final body = shouldShowTrack
        ? '${l10n.playing}: ${currentTrack!.title}'
        : (transitionStatusText ?? l10n.appTitle());

    await _backgroundStatusNotifier.show(
      title: '${_notificationModeLabel(l10n)} - $_notificationTimerLabel',
      body: body,
    );
  }

  String _notificationModeLabel(AppLocalizations l10n) {
    if (_state.pendingMode != null && _state.modeTransitionCountdown > 0) {
      return _state.pendingMode!.isFocus ? l10n.focus : l10n.breakLabel;
    }

    return _state.currentMode.isFocus ? l10n.focus : l10n.breakLabel;
  }

  String get _notificationTimerLabel {
    if (_state.pendingMode != null && _state.modeTransitionCountdown > 0) {
      return _formatNotificationTime(_state.modeTransitionCountdown);
    }

    return _formatNotificationTime(_state.secondsRemaining);
  }

  void _handleMusicPlaybackChanged() {
    notifyListeners();
    if (_isAppInBackground) {
      unawaited(_refreshBackgroundStatusNotification());
    }
  }

  void _setState(TimerViewState nextState) {
    _state = nextState;
    notifyListeners();
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _modeTransitionTimer?.cancel();
    _musicPlaybackController.removeListener(_handleMusicPlaybackChanged);
    _musicPlaybackController.dispose();
    unawaited(_notificationAudioService.dispose());
    unawaited(_backgroundStatusNotifier.cancel());
    unawaited(_eventsController.close());
    super.dispose();
  }
}
