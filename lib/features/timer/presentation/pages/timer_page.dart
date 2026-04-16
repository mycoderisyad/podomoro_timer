import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/l10n.dart';
import '../../../../models/app_settings.dart';
import '../../../../models/statistics.dart';
import '../../../../models/timer_mode.dart';
import '../../../../pages/settings_page.dart';
import '../../../../pages/statistics_page.dart';
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

class _TimerPageState extends State<TimerPage> {
  Timer? _timer;
  Timer? _modeTransitionTimer;
  late final AudioPlayer _notificationPlayer;
  late final MusicPlaybackController _musicPlaybackController;
  int _secondsRemaining = 1500;
  int _modeTransitionCountdown = 0;
  bool _isRunning = false;
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
    _settings = widget.initialSettings;
    _statistics = Statistics();
    _notificationPlayer = AudioPlayer();
    _musicPlaybackController = MusicPlaybackController(
      shouldAutoPlay: () => _shouldSyncMusicToTimer,
    );
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
      return;
    }

    unawaited(_musicPlaybackController.syncPlayback());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _modeTransitionTimer?.cancel();
    _musicPlaybackController.dispose();
    _notificationPlayer.dispose();
    super.dispose();
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
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    if (_isTransitioningMode) {
      return;
    }

    _timer?.cancel();
    setState(() => _isRunning = false);
    _applyMusicSyncState();
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
  }

  Future<void> _handleSyncMusicChanged(bool value) async {
    setState(() => _settings.syncMusicWithTimer = value);
    await SettingsService.saveSettings(_settings);
    await _musicPlaybackController.syncPlayback();
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
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.timerL10n;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > AppConstants.largeScreenBreakpoint;
    final isLandscape = screenWidth > screenHeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'P O M O D O R O',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            color: AppColors.textPrimary,
            iconSize: 28,
            onPressed: _navigateToStatistics,
            tooltip: l10n.statisticsTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            color: AppColors.textPrimary,
            iconSize: 28,
            onPressed: _navigateToSettings,
            tooltip: l10n.settingsTooltip,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: isLandscape
            ? _buildLandscapeLayout(isLargeScreen)
            : _buildPortraitLayout(isLargeScreen),
      ),
    );
  }

  Widget _buildPortraitLayout(bool isLargeScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactHeight = constraints.maxHeight < 680;
        final content = Column(
          mainAxisSize: isCompactHeight ? MainAxisSize.min : MainAxisSize.max,
          children: [
            if (!isCompactHeight) const Spacer(),
            _buildTimerSection(isLargeScreen, false),
            SizedBox(height: isCompactHeight ? 20 : 0),
            if (!isCompactHeight) const Spacer(),
            TimerControls(
              isRunning: _isRunning,
              currentMode: _currentMode,
              onStartPause: _isRunning ? _pauseTimer : _startTimer,
              onReset: _resetTimer,
              onSwitchMode: _switchMode,
            ),
            SizedBox(height: isCompactHeight ? 20 : 24),
            _buildMusicSection(isLargeScreen),
            SizedBox(height: isCompactHeight ? 16 : 24),
          ],
        );

        if (!isCompactHeight) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: content,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: content,
        );
      },
    );
  }

  Widget _buildLandscapeLayout(bool isLargeScreen) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTimerSection(isLargeScreen, true)),
          const SizedBox(width: 24),
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
                const SizedBox(height: 12),
                _buildMusicSection(isLargeScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection(bool isLargeScreen, bool isLandscape) {
    return TimerCircularDisplay(
      isLargeScreen: isLargeScreen,
      isLandscape: isLandscape,
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
    });
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
  }

  // Keep music controls separate from the timer layout logic.
  Widget _buildMusicSection(bool isLargeScreen) {
    return AnimatedBuilder(
      animation: _musicPlaybackController,
      builder: (context, _) {
        return MusicPlayerSection(
          isLargeScreen: isLargeScreen,
          musicQueue: _musicPlaybackController.musicQueue,
          currentQueueIndex: _musicPlaybackController.currentQueueIndex,
          isMusicPlaying: _musicPlaybackController.isMusicPlaying,
          isRunning: _isRunning,
          syncMusicWithTimer: _settings.syncMusicWithTimer,
          defaultVolume: _settings.defaultVolume,
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
        );
      },
    );
  }
}
