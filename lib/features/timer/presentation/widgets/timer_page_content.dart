import 'dart:async';

import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/features/music/presentation/widgets/music_player_section.dart';
import 'package:podomoro_timer/features/timer/application/timer_controller.dart';
import 'package:podomoro_timer/features/timer/presentation/widgets/timer_circular_display.dart';
import 'package:podomoro_timer/features/timer/presentation/widgets/timer_controls.dart';

class TimerPageContent extends StatelessWidget {
  final TimerController controller;
  final VoidCallback onShowDurationPicker;
  final VoidCallback onShowQueue;
  final VoidCallback onOpenMusicLibrary;

  const TimerPageContent({
    super.key,
    required this.controller,
    required this.onShowDurationPicker,
    required this.onShowQueue,
    required this.onOpenMusicLibrary,
  });

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);

    return SafeArea(
      child: dimens.isLandscape
          ? _LandscapeTimerContent(
              controller: controller,
              onShowDurationPicker: onShowDurationPicker,
              onShowQueue: onShowQueue,
              onOpenMusicLibrary: onOpenMusicLibrary,
            )
          : _PortraitTimerContent(
              controller: controller,
              onShowDurationPicker: onShowDurationPicker,
              onShowQueue: onShowQueue,
              onOpenMusicLibrary: onOpenMusicLibrary,
            ),
    );
  }
}

class _PortraitTimerContent extends StatelessWidget {
  final TimerController controller;
  final VoidCallback onShowDurationPicker;
  final VoidCallback onShowQueue;
  final VoidCallback onOpenMusicLibrary;

  const _PortraitTimerContent({
    required this.controller,
    required this.onShowDurationPicker,
    required this.onShowQueue,
    required this.onOpenMusicLibrary,
  });

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);

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
                _TimerPanel(
                  controller: controller,
                  onShowDurationPicker: onShowDurationPicker,
                ),
                SizedBox(height: dimens.isCompactHeight ? dimens.spacingXL : 0),
                if (!dimens.isCompactHeight) const Spacer(),
                _TimerActions(controller: controller),
                SizedBox(
                  height: dimens.isCompactHeight
                      ? dimens.spacingL
                      : dimens.spacingXXL,
                ),
                _MusicPanel(
                  controller: controller,
                  onShowQueue: onShowQueue,
                  onOpenMusicLibrary: onOpenMusicLibrary,
                ),
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
}

class _LandscapeTimerContent extends StatelessWidget {
  final TimerController controller;
  final VoidCallback onShowDurationPicker;
  final VoidCallback onShowQueue;
  final VoidCallback onOpenMusicLibrary;

  const _LandscapeTimerContent({
    required this.controller,
    required this.onShowDurationPicker,
    required this.onShowQueue,
    required this.onOpenMusicLibrary,
  });

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);

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
              Expanded(
                child: _TimerPanel(
                  controller: controller,
                  onShowDurationPicker: onShowDurationPicker,
                ),
              ),
              SizedBox(width: dimens.spacingXXL),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TimerActions(controller: controller),
                    SizedBox(height: dimens.spacingM),
                    _MusicPanel(
                      controller: controller,
                      onShowQueue: onShowQueue,
                      onOpenMusicLibrary: onOpenMusicLibrary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerPanel extends StatelessWidget {
  final TimerController controller;
  final VoidCallback onShowDurationPicker;

  const _TimerPanel({
    required this.controller,
    required this.onShowDurationPicker,
  });

  @override
  Widget build(BuildContext context) {
    return TimerCircularDisplay(
      isRunning: controller.isRunning || controller.isTransitioningMode,
      currentMode: controller.currentMode,
      modeLabelOverride: controller.transitionModeLabel,
      secondsRemaining: controller.secondsRemaining,
      focusDuration: controller.focusDuration,
      breakDuration: controller.breakDuration,
      sessionLabel: controller.sessionChipLabel,
      statusText: controller.transitionStatusText,
      onTimerTapped: onShowDurationPicker,
    );
  }
}

class _TimerActions extends StatelessWidget {
  final TimerController controller;

  const _TimerActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TimerControls(
      isRunning: controller.isRunning,
      currentMode: controller.currentMode,
      onStartPause: controller.isRunning
          ? controller.pauseTimer
          : controller.startTimer,
      onReset: controller.resetTimer,
      onSwitchMode: controller.switchMode,
    );
  }
}

class _MusicPanel extends StatelessWidget {
  final TimerController controller;
  final VoidCallback onShowQueue;
  final VoidCallback onOpenMusicLibrary;

  const _MusicPanel({
    required this.controller,
    required this.onShowQueue,
    required this.onOpenMusicLibrary,
  });

  @override
  Widget build(BuildContext context) {
    return MusicPlayerSection(
      musicQueue: controller.musicQueue,
      currentQueueIndex: controller.currentQueueIndex,
      isMusicPlaying: controller.isMusicPlaying,
      isRunning: controller.isRunning,
      syncMusicWithTimer: controller.settings.syncMusicWithTimer,
      defaultVolume: controller.settings.defaultVolume,
      playbackPosition: controller.playbackPosition,
      trackDuration: controller.trackDuration,
      onShowQueue: onShowQueue,
      onNavigateToMusicSelection: onOpenMusicLibrary,
      onPlayPrevious: () {
        unawaited(controller.playPreviousTrack());
      },
      onPlayNext: () {
        unawaited(controller.playNextTrack());
      },
      onSyncChanged: (value) {
        unawaited(controller.updateSyncMusic(value));
      },
      onJumpToTrack: (index) {
        unawaited(controller.jumpToTrack(index));
      },
      onVolumeChanged: (value) {
        unawaited(controller.updateDefaultVolume(value));
      },
      onSeek: (position) {
        unawaited(controller.seekTrack(position));
      },
    );
  }
}
