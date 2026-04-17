import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/l10n.dart';
import '../../../../models/app_settings.dart';
import '../../../../models/statistics.dart';
import '../../../../models/timer_mode.dart';
import '../../../../pages/settings_page.dart';
import '../../../../pages/statistics_page.dart';
import '../../../../services/background_status_notification_service.dart';
import '../../../../services/notification_audio_service.dart';
import '../../../../services/settings_service.dart';
import '../../../../services/statistics_service.dart';
import '../../../../widgets/duration_picker_sheet.dart';
import '../../../../widgets/timer_circular_display.dart';
import '../../../../widgets/timer_controls.dart';
import '../../../music/application/music_playback_controller.dart';
import '../../../music/domain/music_track.dart';
import '../../../music/presentation/pages/music_selection_page.dart';
import '../../../music/presentation/widgets/music_player_section.dart';
import '../../../music/presentation/widgets/music_queue_sheet.dart';

class TimerPage extends StatefulWidget {
  final AppSettings initialSettings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const TimerPage({
    super.key,
    required this.initialSettings,
    required this.onSettingsChanged,
  });

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  Timer? _timer;
  Timer? _modeTransitionTimer;
  late final AudioPlayer _notificationPlayer;
  late final MusicPlaybackController _musicPlaybackController;
  int _secondsRemaining = 1500;
  int _modeTransitionCountdown = 0;
  bool _isRunning = false;
  bool _isAppInBackground = false;
  TimerMode _currentMode = TimerMode.focus;
  TimerMode? _pendingMode;
  bool _shouldAutoStartPendingMode = false;
  late AppSettings _settings;
  late Statistics _statistics;

  static const List<int> _focusDurationOptions = [
    900,
    1200,
    1500,
    1800,
    2100,
    2700,
    3000,
  ];
  static const List<int> _breakDurationOptions = [180, 300, 420, 600, 900];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settings = widget.initialSettings;
    _statistics = Statistics();
    _notificationPlayer = AudioPlayer();
    _musicPlaybackController = MusicPlaybackController(
      shouldAutoPlay: () => _shouldSyncMusicToTimer,
    );
    _musicPlaybackController.addListener(_handleMusicPlaybackChanged);
    unawaited(_musicPlaybackController.initialize(_settings.defaultVolume));
    _secondsRemaining = _settings.focusDuration;
    _runAutoClear();
  }

  Future<void> _runAutoClear() async {
    await StatisticsService.runAutoClearIfNeeded(_settings.autoClearSchedule);
  }

  bool get _shouldSyncMusicToTimer =>
      _settings.syncMusicWithTimer &&
      _isRunning &&
      _musicPlaybackController.musicQueue.isNotEmpty;

  void _applyMusicSyncState() {
    if (_musicPlaybackController.musicQueue.isEmpty) {
      if (_isAppInBackground) {
        unawaited(_refreshBackgroundStatusNotification());
      }
      return;
    }

    unawaited(_musicPlaybackController.syncPlayback());
    if (_isAppInBackground) {
      unawaited(_refreshBackgroundStatusNotification());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _modeTransitionTimer?.cancel();
    _musicPlaybackController.removeListener(_handleMusicPlaybackChanged);
    _musicPlaybackController.dispose();
    _notificationPlayer.dispose();
    unawaited(BackgroundStatusNotificationService.cancel());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInBackground = false;
        unawaited(BackgroundStatusNotificationService.cancel());
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _isAppInBackground = true;
        unawaited(_refreshBackgroundStatusNotification());
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _handleMusicPlaybackChanged() {
    if (_isAppInBackground) {
      unawaited(_refreshBackgroundStatusNotification());
    }
  }

  void _startTimer() {
    if (_isTransitioningMode) {
      return;
    }

    if (_timer != null && _timer!.isActive) {
      return;
    }

    setState(() => _isRunning = true);
    _applyMusicSyncState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
          if (_currentMode == TimerMode.focus) {
            _statistics.totalFocusSeconds++;
          } else {
            _statistics.totalBreakSeconds++;
          }
        });
        if (_isAppInBackground) {
          unawaited(_refreshBackgroundStatusNotification());
        }
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        if (_isAppInBackground) {
          unawaited(_refreshBackgroundStatusNotification());
        }
        _onTimerComplete();
      }
    });
    if (_isAppInBackground) {
      unawaited(_refreshBackgroundStatusNotification());
    }
  }

  void _pauseTimer() {
    if (_isTransitioningMode) {
      return;
    }

    _timer?.cancel();
    setState(() => _isRunning = false);
    _applyMusicSyncState();
    if (_isAppInBackground) {
      unawaited(_refreshBackgroundStatusNotification());
    }
  }

  void _resetTimer() {
    _cancelPendingModeTransition();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _currentMode == TimerMode.focus
          ? _settings.focusDuration
          : _settings.breakDuration;
    });
    _applyMusicSyncState();
    if (_isAppInBackground) {
      unawaited(_refreshBackgroundStatusNotification());
    }
  }

  void _switchMode() {
    _cancelPendingModeTransition();
    _pauseTimer();
    setState(() {
      _currentMode = _currentMode == TimerMode.focus
          ? TimerMode.break_
          : TimerMode.focus;
      _secondsRemaining = _currentMode == TimerMode.focus
          ? _settings.focusDuration
          : _settings.breakDuration;
    });
    if (_isAppInBackground) {
      unawaited(_refreshBackgroundStatusNotification());
    }
  }

  void _onTimerComplete() {
    final l10n = context.timerL10n;
    _statistics.checkAndResetDaily();
    _applyMusicSyncState();
    unawaited(_playNotificationSound());

    if (_currentMode == TimerMode.focus) {
      setState(() => _statistics.completedSessions++);

      StatisticsService.addOrUpdateToday(
        focusSeconds: _settings.focusDuration,
        completedSessions: 1,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.focusSessionCompleteMessage),
          duration: const Duration(seconds: 3),
        ),
      );

      _scheduleModeTransition(
        nextMode: TimerMode.break_,
        autoStartNextTimer: _settings.autoStartBreak,
      );
    } else {
      StatisticsService.addOrUpdateToday(breakSeconds: _settings.breakDuration);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.breakEndedMessage),
          duration: const Duration(seconds: 3),
        ),
      );
      _scheduleModeTransition(
        nextMode: TimerMode.focus,
        autoStartNextTimer: false,
      );
    }
  }

  Future<void> _playNotificationSound() async {
    if (!_settings.soundEnabled) {
      return;
    }
    try {
      await NotificationAudioService.playAsset(
        player: _notificationPlayer,
        assetPath: _settings.notificationSound,
        volume: _settings.notificationVolume,
      );
    } catch (error) {
      debugPrint('Failed to play notification sound: $error');
    }
  }

  Future<void> _replaceMusicQueue(List<MusicTrack> queue) async {
    await _musicPlaybackController.setQueue(queue);
    _applyMusicSyncState();
    if (_isAppInBackground) {
      await _refreshBackgroundStatusNotification();
    }
  }

  Future<void> _handleSyncMusicChanged(bool value) async {
    setState(() => _settings.syncMusicWithTimer = value);
    await SettingsService.saveSettings(_settings);
    await _musicPlaybackController.syncPlayback();
    if (_isAppInBackground) {
      await _refreshBackgroundStatusNotification();
    }
  }

  void _showQueueBottomSheet() {
    if (_musicPlaybackController.musicQueue.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => MusicQueueSheet(
        musicQueue: _musicPlaybackController.musicQueue,
        currentQueueIndex: _musicPlaybackController.currentQueueIndex,
        isMusicPlaying: _musicPlaybackController.isMusicPlaying,
        onJumpToTrack: (index) {
          unawaited(
            _musicPlaybackController.jumpToTrack(
              index,
              autoplay: _shouldSyncMusicToTimer,
            ),
          );
        },
      ),
    );
  }

  Future<void> _navigateToMusicSelection() async {
    final result = await Navigator.push<List<MusicTrack>>(
      context,
      MaterialPageRoute(
        builder: (context) => MusicSelectionPage(
          currentQueue: _musicPlaybackController.musicQueue,
        ),
      ),
    );

    if (result != null && mounted) {
      await _replaceMusicQueue(result);
    }
  }

  // Keep secondary screens isolated from the timer loop.
  Future<void> _navigateToStatistics() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatisticsPage()),
    );
  }

  Future<void> _navigateToSettings() async {
    final result = await Navigator.push<AppSettings>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(settings: _settings),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _settings = result;
      });
      await _musicPlaybackController.setVolume(_settings.defaultVolume);
      await SettingsService.saveSettings(_settings);
      widget.onSettingsChanged(_settings);
      _applyMusicSyncState();
      if (_isAppInBackground) {
        await _refreshBackgroundStatusNotification();
      }
    }
  }

  void _showDurationPicker() {
    if (_isTransitioningMode) {
      return;
    }

    final options = _currentMode == TimerMode.focus
        ? _focusDurationOptions
        : _breakDurationOptions;
    final currentDuration = _currentMode == TimerMode.focus
        ? _settings.focusDuration
        : _settings.breakDuration;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DurationPickerSheet(
        title: _currentMode == TimerMode.focus
            ? context.timerL10n.focusDuration
            : context.timerL10n.breakDuration,
        options: options,
        currentValue: currentDuration,
        onSelected: (duration) {
          setState(() {
            if (_currentMode == TimerMode.focus) {
              _settings.focusDuration = duration;
            } else {
              _settings.breakDuration = duration;
            }
            _secondsRemaining = duration;
          });
          SettingsService.saveSettings(_settings);
          if (_isAppInBackground) {
            unawaited(_refreshBackgroundStatusNotification());
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.timerL10n;
    final dimens = AppDimens.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'P O M O D O R O',
          style: AppTypography.of(
            context,
          ).bodyLarge.copyWith(fontWeight: FontWeight.bold, letterSpacing: 4),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            color: AppColors.textPrimary,
            iconSize: AppDimens.of(context).appBarIconSize,
            onPressed: _navigateToStatistics,
            tooltip: l10n.statisticsTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            color: AppColors.textPrimary,
            iconSize: AppDimens.of(context).appBarIconSize,
            onPressed: _navigateToSettings,
            tooltip: l10n.settingsTooltip,
          ),
          SizedBox(width: AppDimens.of(context).spacingS),
        ],
      ),
      body: SafeArea(
        child: dimens.isLandscape
            ? _buildLandscapeLayout(dimens)
            : _buildPortraitLayout(dimens),
      ),
    );
  }

  Widget _buildPortraitLayout(AppDimens dimens) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dimens.maxContentWidth),
            child: Column(
              mainAxisSize: dimens.isCompactHeight
                  ? MainAxisSize.min
                  : MainAxisSize.max,
              children: [
                if (!dimens.isCompactHeight) const Spacer(),
                _buildTimerSection(),
                SizedBox(height: dimens.isCompactHeight ? dimens.spacingXL : 0),
                if (!dimens.isCompactHeight) const Spacer(),
                TimerControls(
                  isRunning: _isRunning,
                  currentMode: _currentMode,
                  onStartPause: _isRunning ? _pauseTimer : _startTimer,
                  onReset: _resetTimer,
                  onSwitchMode: _switchMode,
                ),
                SizedBox(
                  height: dimens.isCompactHeight
                      ? dimens.spacingL
                      : dimens.spacingXXL,
                ),
                _buildMusicSection(),
                SizedBox(
                  height: dimens.isCompactHeight
                      ? dimens.spacingL
                      : dimens.spacingXXL,
                ),
              ],
            ),
          ),
        );

        if (!dimens.isCompactHeight) {
          return Padding(padding: dimens.paddingHorizontalXXL, child: content);
        }

        return SingleChildScrollView(
          padding: dimens.pagePadding,
          child: content,
        );
      },
    );
  }

  Widget _buildLandscapeLayout(AppDimens dimens) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: dimens.spacingXXL,
        vertical: dimens.spacingS,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTimerSection()),
              SizedBox(width: dimens.spacingXXL),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TimerControls(
                      isRunning: _isRunning,
                      currentMode: _currentMode,
                      onStartPause: _isRunning ? _pauseTimer : _startTimer,
                      onReset: _resetTimer,
                      onSwitchMode: _switchMode,
                    ),
                    SizedBox(height: dimens.spacingM),
                    _buildMusicSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    return TimerCircularDisplay(
      isRunning: _isRunning || _isTransitioningMode,
      currentMode: _currentMode,
      modeLabelOverride: _transitionModeLabel,
      secondsRemaining: _secondsRemaining,
      focusDuration: _settings.focusDuration,
      breakDuration: _settings.breakDuration,
      completedSessions: _statistics.completedSessions,
      statusText: _transitionStatusText,
      onTimerTapped: _showDurationPicker,
    );
  }

  bool get _isTransitioningMode => _pendingMode != null;

  // Show transition labels inside the timer ring while waiting.
  String? get _transitionModeLabel {
    if (_pendingMode == null) {
      return null;
    }

    final nextModeLabel = _pendingMode == TimerMode.focus
        ? context.timerL10n.focus
        : context.timerL10n.breakLabel;
    return context.timerL10n.headingToModeLabel(nextModeLabel);
  }

  String? get _transitionStatusText {
    if (_pendingMode == null || _modeTransitionCountdown <= 0) {
      return null;
    }

    final nextModeLabel = _pendingMode == TimerMode.focus
        ? context.timerL10n.focus
        : context.timerL10n.breakLabel;
    return context.timerL10n.transitionStatusLabel(
      nextModeLabel,
      _modeTransitionCountdown,
    );
  }

  // Pause between modes before the next countdown starts.
  void _scheduleModeTransition({
    required TimerMode nextMode,
    required bool autoStartNextTimer,
  }) {
    _cancelPendingModeTransition();

    final delaySeconds = _settings.modeTransitionDelaySeconds;
    if (delaySeconds <= 0) {
      _completeModeTransition(
        nextMode: nextMode,
        autoStartNextTimer: autoStartNextTimer,
      );
      return;
    }

    setState(() {
      _pendingMode = nextMode;
      _shouldAutoStartPendingMode = autoStartNextTimer;
      _modeTransitionCountdown = delaySeconds;
    });

    _modeTransitionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_modeTransitionCountdown <= 1) {
        timer.cancel();
        _completeModeTransition(
          nextMode: nextMode,
          autoStartNextTimer: _shouldAutoStartPendingMode,
        );
        return;
      }

      setState(() {
        _modeTransitionCountdown--;
      });
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

    setState(() {
      _pendingMode = null;
      _shouldAutoStartPendingMode = false;
      _modeTransitionCountdown = 0;
      _currentMode = nextMode;
      _secondsRemaining = nextMode == TimerMode.focus
          ? _settings.focusDuration
          : _settings.breakDuration;
    });
    if (_isAppInBackground) {
      unawaited(_refreshBackgroundStatusNotification());
    }

    if (autoStartNextTimer) {
      _startTimer();
    }
  }

  void _cancelPendingModeTransition() {
    _modeTransitionTimer?.cancel();
    _modeTransitionTimer = null;

    if (!_isTransitioningMode) {
      return;
    }

    setState(() {
      _pendingMode = null;
      _shouldAutoStartPendingMode = false;
      _modeTransitionCountdown = 0;
    });
    if (_isAppInBackground) {
      unawaited(_refreshBackgroundStatusNotification());
    }
  }

  String _formatNotificationTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _notificationModeLabel {
    if (_pendingMode != null && _modeTransitionCountdown > 0) {
      return _pendingMode == TimerMode.focus
          ? context.timerL10n.focus
          : context.timerL10n.breakLabel;
    }

    return _currentMode == TimerMode.focus
        ? context.timerL10n.focus
        : context.timerL10n.breakLabel;
  }

  String get _notificationTimerLabel {
    if (_pendingMode != null && _modeTransitionCountdown > 0) {
      return _formatNotificationTime(_modeTransitionCountdown);
    }

    return _formatNotificationTime(_secondsRemaining);
  }

  Future<void> _refreshBackgroundStatusNotification() async {
    if (!mounted || !_isAppInBackground) {
      return;
    }

    final currentTrack = _musicPlaybackController.currentTrack;
    final shouldShowTrack =
        _settings.syncMusicWithTimer &&
        currentTrack != null &&
        _musicPlaybackController.musicQueue.isNotEmpty;

    final body = shouldShowTrack
        ? '${context.musicL10n.playing}: ${currentTrack.title}'
        : (_transitionStatusText ?? context.l10n.appTitle());

    await BackgroundStatusNotificationService.show(
      title: '$_notificationModeLabel • $_notificationTimerLabel',
      body: body,
    );
  }

  // Keep music controls separate from the timer layout logic.
  Widget _buildMusicSection() {
    return AnimatedBuilder(
      animation: _musicPlaybackController,
      builder: (context, _) {
        return MusicPlayerSection(
          musicQueue: _musicPlaybackController.musicQueue,
          currentQueueIndex: _musicPlaybackController.currentQueueIndex,
          isMusicPlaying: _musicPlaybackController.isMusicPlaying,
          isRunning: _isRunning,
          syncMusicWithTimer: _settings.syncMusicWithTimer,
          defaultVolume: _settings.defaultVolume,
          playbackPosition: _musicPlaybackController.playbackPosition,
          trackDuration: _musicPlaybackController.trackDuration,
          onShowQueue: _showQueueBottomSheet,
          onNavigateToMusicSelection: _navigateToMusicSelection,
          onPlayPrevious: () {
            unawaited(
              _musicPlaybackController.playPrevious(
                autoplay: _shouldSyncMusicToTimer,
              ),
            );
          },
          onPlayNext: () {
            unawaited(
              _musicPlaybackController.playNext(
                autoplay: _shouldSyncMusicToTimer,
              ),
            );
          },
          onSyncChanged: _handleSyncMusicChanged,
          onJumpToTrack: (index) {
            unawaited(
              _musicPlaybackController.jumpToTrack(
                index,
                autoplay: _shouldSyncMusicToTimer,
              ),
            );
          },
          onVolumeChanged: (value) {
            setState(() => _settings.defaultVolume = value);
            unawaited(_musicPlaybackController.setVolume(value));
            unawaited(SettingsService.saveSettings(_settings));
          },
          onSeek: (position) {
            unawaited(_musicPlaybackController.seek(position));
          },
        );
      },
    );
  }
}
