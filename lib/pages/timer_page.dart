import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/timer_mode.dart';
import '../models/music_track.dart';
import '../models/app_settings.dart';
import '../models/statistics.dart';
import '../widgets/timer_display.dart';
import 'music_selection_page.dart';
import 'statistics_page.dart';
import 'settings_page.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? _timer;
  late AudioPlayer _audioPlayer;
  int _secondsRemaining = 1500;
  bool _isRunning = false;
  TimerMode _currentMode = TimerMode.focus;
  MusicTrack? _selectedMusic;
  bool _isMusicPlaying = false;
  late AppSettings _settings;
  late Statistics _statistics;

  static const List<int> _focusDurationOptions = [900, 1200, 1500, 1800, 2100, 2700, 3000];
  static const List<int> _breakDurationOptions = [180, 300, 420, 600, 900];

  @override
  void initState() {
    super.initState();
    _settings = AppSettings();
    _statistics = Statistics();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.setVolume(_settings.defaultVolume);
    _secondsRemaining = _settings.focusDuration;

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isMusicPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return;

    setState(() {
      _isRunning = true;
    });

    if (_settings.syncMusicWithTimer && _selectedMusic != null) {
      _playOrResumeMusic();
    }

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
        setState(() {
          _isRunning = false;
        });
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });

    if (_settings.syncMusicWithTimer && _isMusicPlaying) {
      _pauseMusic();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _currentMode == TimerMode.focus
          ? _settings.focusDuration
          : _settings.breakDuration;
    });

    if (_settings.syncMusicWithTimer && _isMusicPlaying) {
      _pauseMusic();
    }
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
    _statistics.checkAndResetDaily();
    if (_currentMode == TimerMode.focus) {
      setState(() {
        _statistics.completedSessions++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Focus session complete! Time for a break.'),
          duration: Duration(seconds: 3),
        ),
      );
      if (_settings.autoStartBreak) {
        _switchMode();
        _startTimer();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Break time over! Ready to focus again?'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _playOrResumeMusic() async {
    if (_selectedMusic == null) return;

    try {
      if (_audioPlayer.state == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource(_selectedMusic!.assetPath));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing music: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _pauseMusic() async {
    await _audioPlayer.pause();
  }

  Future<void> _navigateToMusicSelection() async {
    final result = await Navigator.push<MusicTrack>(
      context,
      MaterialPageRoute(builder: (context) => const MusicSelectionPage()),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedMusic = result;
      });
    }
  }

  Future<void> _navigateToStatistics() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsPage(statistics: _statistics),
      ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _DurationPickerSheet(
        title: _currentMode == TimerMode.focus
            ? 'Focus Duration'
            : 'Break Duration',
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
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            icon:
                const Icon(Icons.bar_chart_rounded, color: AppColors.textPrimary),
            onPressed: _navigateToStatistics,
          ),
          IconButton(
            icon:
                const Icon(Icons.settings_rounded, color: AppColors.textPrimary),
            onPressed: _navigateToSettings,
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
          _buildControlButtons(),
          const SizedBox(height: 16),
          _buildSwitchModeButton(),
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
                _buildControlButtons(),
                const SizedBox(height: 12),
                _buildSwitchModeButton(),
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
    final timerSize = isLandscape
        ? 180.0
        : (isLargeScreen ? AppConstants.timerSizeLarge : AppConstants.timerSizeSmall);
    final fontSize = isLandscape
        ? 48.0
        : (isLargeScreen ? AppConstants.timerFontSizeLarge : AppConstants.timerFontSizeSmall);

    return GestureDetector(
      onTap: _isRunning ? null : _showDurationPicker,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: timerSize,
            height: timerSize,
            child: CircularProgressIndicator(
              value: 1 -
                  (_secondsRemaining /
                      (_currentMode == TimerMode.focus
                          ? _settings.focusDuration
                          : _settings.breakDuration)),
              strokeWidth: AppConstants.progressStrokeWidth,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentMode == TimerMode.focus ? 'FOCUS' : 'BREAK',
                style: const TextStyle(
                  fontSize: 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              TimerDisplay(
                seconds: _secondsRemaining,
                fontSize: fontSize,
                color: AppColors.textPrimary,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Session #${_statistics.completedSessions}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
            label: _isRunning ? 'Pause' : 'Start',
            onPressed: _isRunning ? _pauseTimer : _startTimer,
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.refresh_rounded,
            label: 'Reset',
            onPressed: _resetTimer,
            isPrimary: false,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchModeButton() {
    final targetMode =
        _currentMode == TimerMode.focus ? 'Break' : 'Focus';
    return SizedBox(
      width: double.infinity,
      child: _ActionButton(
        icon: Icons.swap_horiz_rounded,
        label: 'Switch to $targetMode',
        onPressed: _switchMode,
        isPrimary: false,
        isFullWidth: true,
      ),
    );
  }

  Widget _buildMusicSection(bool isLargeScreen) {
    return Container(
      width: isLargeScreen ? 500 : double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _navigateToMusicSelection,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMusic?.title ?? "No Music Selected",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        "Tap to select",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Switch(
                value: _settings.syncMusicWithTimer,
                onChanged: _selectedMusic != null
                    ? (value) {
                        setState(() {
                          _settings.syncMusicWithTimer = value;
                        });
                      }
                    : null,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
          if (_selectedMusic != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.volume_down_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                Expanded(
                  child: Slider(
                    value: _settings.defaultVolume,
                    onChanged: (value) {
                      setState(() => _settings.defaultVolume = value);
                      _audioPlayer.setVolume(value);
                    },
                  ),
                ),
                Text(
                  '${(_settings.defaultVolume * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isFullWidth;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isPrimary,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary ? AppColors.white : AppColors.textPrimary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationPickerSheet extends StatelessWidget {
  final String title;
  final List<int> options;
  final int currentValue;
  final ValueChanged<int> onSelected;

  const _DurationPickerSheet({
    required this.title,
    required this.options,
    required this.currentValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((duration) {
              final isSelected = currentValue == duration;
              final minutes = duration ~/ 60;
              return GestureDetector(
                onTap: () => onSelected(duration),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.secondary,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '$minutes min',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
