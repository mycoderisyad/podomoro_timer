import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../l10n/l10n.dart';
import '../models/timer_mode.dart';
import '../models/music_track.dart';
import '../models/app_settings.dart';
import '../models/statistics.dart';
import '../widgets/duration_picker_sheet.dart';
import '../widgets/timer_circular_display.dart';
import '../widgets/timer_controls.dart';
import '../widgets/music_player_section.dart';
import '../widgets/music_queue_sheet.dart';
import '../services/notification_audio_service.dart';
import '../services/settings_service.dart';
import '../services/statistics_service.dart';
import 'music_selection_page.dart';
import 'statistics_page.dart';
import 'settings_page.dart';

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
  late AudioPlayer _audioPlayer;
  late AudioPlayer _notificationPlayer;
  int _secondsRemaining = 1500;
  bool _isRunning = false;
  TimerMode _currentMode = TimerMode.focus;
  List<MusicTrack> _musicQueue = [];
  int _currentQueueIndex = 0;
  bool _isMusicPlaying = false;
  late AppSettings _settings;
  late Statistics _statistics;

  static const List<int> _focusDurationOptions = [
    900, 1200, 1500, 1800, 2100, 2700, 3000,
  ];
  static const List<int> _breakDurationOptions = [
    180, 300, 420, 600, 900,
  ];

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
    _statistics = Statistics();
    _audioPlayer = AudioPlayer();
    _notificationPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setVolume(_settings.defaultVolume);
    _secondsRemaining = _settings.focusDuration;

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() => _isMusicPlaying = state == PlayerState.playing);
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (_shouldSyncMusicToTimer) {
        _playNextInQueue();
      }
    });

    _runAutoClear();
  }

  Future<void> _runAutoClear() async {
    await StatisticsService.runAutoClearIfNeeded(_settings.autoClearSchedule);
  }

  bool get _shouldSyncMusicToTimer =>
      _settings.syncMusicWithTimer && _isRunning && _musicQueue.isNotEmpty;

  void _applyMusicSyncState() {
    if (_musicQueue.isEmpty) return;

    if (_shouldSyncMusicToTimer) {
      unawaited(_playOrResumeMusic());
      return;
    }

    if (_audioPlayer.state == PlayerState.playing) {
      unawaited(_pauseMusic());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _notificationPlayer.dispose();
    super.dispose();
  }

  // --- Timer Controls ---

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return;

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
    _timer?.cancel();
    setState(() => _isRunning = false);
    _applyMusicSyncState();
  }

  void _resetTimer() {
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
    _pauseTimer();
    setState(() {
      _currentMode =
          _currentMode == TimerMode.focus ? TimerMode.break_ : TimerMode.focus;
      _secondsRemaining = _currentMode == TimerMode.focus
          ? _settings.focusDuration
          : _settings.breakDuration;
    });
  }

  void _onTimerComplete() {
    final l10n = context.l10n;
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

      if (_settings.autoStartBreak) {
        _switchMode();
        _startTimer();
      }
    } else {
      StatisticsService.addOrUpdateToday(
        breakSeconds: _settings.breakDuration,
      );

      _showBreakEndDialog();
    }
  }

  Future<void> _playNotificationSound() async {
    if (!_settings.soundEnabled) return;
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

  Future<void> _showBreakEndDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.breakEndedTitle),
        content: Text(context.l10n.breakEndedMessage),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.ok),
          ),
        ],
      ),
    );
  }

  // --- Music Controls ---

  Future<void> _playOrResumeMusic() async {
    if (_musicQueue.isEmpty) return;

    try {
      if (_audioPlayer.state == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        await _playCurrentTrack();
      }
    } catch (_) {
      _playNextInQueue();
    }
  }

  Future<void> _playCurrentTrack() async {
    if (_musicQueue.isEmpty) return;

    final currentTrack = _musicQueue[_currentQueueIndex];

    try {
      await _audioPlayer.stop();

      if (currentTrack.isLocalFile) {
        await _audioPlayer.play(DeviceFileSource(currentTrack.filePath!));
      } else if (currentTrack.assetPath.isNotEmpty) {
        await _audioPlayer.play(AssetSource(currentTrack.assetPath));
      }
    } catch (_) {
      _playNextInQueue();
    }
  }

  void _playNextInQueue() {
    if (_musicQueue.isEmpty) return;

    setState(() {
      _currentQueueIndex = (_currentQueueIndex + 1) % _musicQueue.length;
    });

    if (_shouldSyncMusicToTimer) {
      _playCurrentTrack();
    }
  }

  void _playPreviousInQueue() {
    if (_musicQueue.isEmpty) return;

    setState(() {
      _currentQueueIndex =
          (_currentQueueIndex - 1 + _musicQueue.length) % _musicQueue.length;
    });

    if (_shouldSyncMusicToTimer) {
      _playCurrentTrack();
    }
  }

  void _jumpToTrack(int index) {
    if (_musicQueue.isEmpty || index < 0 || index >= _musicQueue.length) {
      return;
    }

    setState(() => _currentQueueIndex = index);

    if (_isRunning && _settings.syncMusicWithTimer) {
      _playCurrentTrack();
    }
  }

  Future<void> _pauseMusic() async {
    await _audioPlayer.pause();
  }

  Future<void> _replaceMusicQueue(List<MusicTrack> queue) async {
    await _audioPlayer.stop();

    if (!mounted) return;

    setState(() {
      _musicQueue = queue;
      _currentQueueIndex = 0;
      _isMusicPlaying = false;
    });

    _applyMusicSyncState();
  }

  Future<void> _handleSyncMusicChanged(bool value) async {
    setState(() => _settings.syncMusicWithTimer = value);
    await SettingsService.saveSettings(_settings);

    if (value) {
      _applyMusicSyncState();
      return;
    }

    if (_audioPlayer.state == PlayerState.playing) {
      await _pauseMusic();
    }
  }

  // --- Navigation ---

  void _showQueueBottomSheet() {
    if (_musicQueue.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => MusicQueueSheet(
        musicQueue: _musicQueue,
        currentQueueIndex: _currentQueueIndex,
        isMusicPlaying: _isMusicPlaying,
        onJumpToTrack: _jumpToTrack,
      ),
    );
  }

  Future<void> _navigateToMusicSelection() async {
    final result = await Navigator.push<List<MusicTrack>>(
      context,
      MaterialPageRoute(
        builder: (context) => MusicSelectionPage(currentQueue: _musicQueue),
      ),
    );

    if (result != null && mounted) {
      await _replaceMusicQueue(result);
    }
  }

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
        _audioPlayer.setVolume(_settings.defaultVolume);
      });
      await SettingsService.saveSettings(_settings);
      widget.onSettingsChanged(_settings);
      _applyMusicSyncState();
    }
  }

  void _showDurationPicker() {
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
            ? context.l10n.focusDuration
            : context.l10n.breakDuration,
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

  // --- Build UI ---

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          "P O M O D O R O",
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 1),
          _buildTimerSection(isLargeScreen, false),
          const Spacer(flex: 1),
          TimerControls(
            isRunning: _isRunning,
            currentMode: _currentMode,
            onStartPause: _isRunning ? _pauseTimer : _startTimer,
            onReset: _resetTimer,
            onSwitchMode: _switchMode,
          ),
          const SizedBox(height: 24),
          _buildMusicSection(isLargeScreen),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(bool isLargeScreen) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: _buildTimerSection(isLargeScreen, true),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
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
      isRunning: _isRunning,
      currentMode: _currentMode,
      secondsRemaining: _secondsRemaining,
      focusDuration: _settings.focusDuration,
      breakDuration: _settings.breakDuration,
      completedSessions: _statistics.completedSessions,
      onTimerTapped: _showDurationPicker,
    );
  }

  Widget _buildMusicSection(bool isLargeScreen) {
    return MusicPlayerSection(
      isLargeScreen: isLargeScreen,
      musicQueue: _musicQueue,
      currentQueueIndex: _currentQueueIndex,
      isMusicPlaying: _isMusicPlaying,
      isRunning: _isRunning,
      syncMusicWithTimer: _settings.syncMusicWithTimer,
      defaultVolume: _settings.defaultVolume,
      onShowQueue: _showQueueBottomSheet,
      onNavigateToMusicSelection: _navigateToMusicSelection,
      onPlayPrevious: _playPreviousInQueue,
      onPlayNext: _playNextInQueue,
      onSyncChanged: _handleSyncMusicChanged,
      onJumpToTrack: _jumpToTrack,
      onVolumeChanged: (value) {
        setState(() => _settings.defaultVolume = value);
        _audioPlayer.setVolume(value);
        SettingsService.saveSettings(_settings);
      },
    );
  }
}
