import 'dart:async';

import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/features/music/domain/music_track.dart';
import 'package:podomoro_timer/features/music/presentation/pages/music_selection_page.dart';
import 'package:podomoro_timer/features/music/presentation/widgets/music_queue_sheet.dart';
import 'package:podomoro_timer/features/settings/presentation/pages/settings_page.dart';
import 'package:podomoro_timer/features/statistics/presentation/pages/statistics_page.dart';
import 'package:podomoro_timer/features/timer/application/timer_controller.dart';
import 'package:podomoro_timer/features/timer/application/timer_ui_event.dart';
import 'package:podomoro_timer/features/timer/domain/timer_mode.dart';
import 'package:podomoro_timer/features/timer/presentation/widgets/duration_picker_sheet.dart';
import 'package:podomoro_timer/features/timer/presentation/widgets/timer_page_app_bar.dart';
import 'package:podomoro_timer/features/timer/presentation/widgets/timer_page_content.dart';
import 'package:podomoro_timer/l10n/l10n.dart';
import 'package:podomoro_timer/shared/services/background_status_notifier.dart';
import 'package:podomoro_timer/shared/services/notification_audio_service.dart';
import 'package:podomoro_timer/shared/settings/app_settings.dart';
import 'package:podomoro_timer/shared/settings/settings_repository.dart';
import 'package:podomoro_timer/shared/statistics/statistics_repository.dart';

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
  late final TimerController _controller;
  StreamSubscription<TimerUiEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = TimerController(
      initialSettings: widget.initialSettings,
      settingsRepository: const SharedPreferencesSettingsRepository(),
      statisticsRepository: SharedPreferencesStatisticsRepository(),
      notificationAudioService: AudioPlayerNotificationAudioService(),
      backgroundStatusNotifier: LocalNotificationsBackgroundStatusNotifier(),
    );
    _eventSubscription = _controller.events.listen(_handleTimerEvent);
    unawaited(_controller.initialize());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.bindLocalizations(context.l10n);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(_controller.handleLifecycleChange(state));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_eventSubscription?.cancel());
    _controller.dispose();
    super.dispose();
  }

  void _handleTimerEvent(TimerUiEvent event) {
    if (!mounted) {
      return;
    }

    final message = switch (event.type) {
      TimerUiEventType.focusSessionCompleted =>
        context.timerL10n.focusSessionCompleteMessage,
      TimerUiEventType.breakCompleted => context.timerL10n.breakEndedMessage,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _openStatistics() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatisticsPage()),
    );
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push<AppSettings>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(settings: _controller.settings),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    await _controller.applySettings(result);
    widget.onSettingsChanged(result);
  }

  Future<void> _openMusicLibrary() async {
    final result = await Navigator.push<List<MusicTrack>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MusicSelectionPage(currentQueue: _controller.musicQueue),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    await _controller.replaceMusicQueue(result);
  }

  void _showQueueBottomSheet() {
    if (_controller.musicQueue.isEmpty) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => MusicQueueSheet(
        musicQueue: _controller.musicQueue,
        currentQueueIndex: _controller.currentQueueIndex,
        isMusicPlaying: _controller.isMusicPlaying,
        onJumpToTrack: (index) {
          unawaited(_controller.jumpToTrack(index));
        },
      ),
    );
  }

  void _showDurationPicker() {
    if (_controller.isTransitioningMode) {
      return;
    }

    final isFocus = _controller.currentMode.isFocus;
    final options = isFocus
        ? TimerController.focusDurationOptions
        : TimerController.breakDurationOptions;
    final currentDuration = isFocus
        ? _controller.settings.focusDuration
        : _controller.settings.breakDuration;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DurationPickerSheet(
        title: isFocus
            ? context.timerL10n.focusDuration
            : context.timerL10n.breakDuration,
        options: options,
        currentValue: currentDuration,
        initialSessionName: _controller.nextFocusSessionNameOverride,
        showSessionNameInput: isFocus,
        onSelected: (result) async {
          await _controller.updateCurrentDuration(
            durationSeconds: result.durationSeconds,
            sessionName: result.sessionName,
          );
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _controller.bindLocalizations(context.l10n);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          extendBodyBehindAppBar: true,
          appBar: TimerPageAppBar(
            onOpenStatistics: _openStatistics,
            onOpenSettings: _openSettings,
          ),
          body: TimerPageContent(
            controller: _controller,
            onShowDurationPicker: _showDurationPicker,
            onShowQueue: _showQueueBottomSheet,
            onOpenMusicLibrary: _openMusicLibrary,
          ),
        );
      },
    );
  }
}
