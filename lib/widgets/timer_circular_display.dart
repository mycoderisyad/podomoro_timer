import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../l10n/l10n.dart';
import '../models/timer_mode.dart';
import 'timer_display.dart';

class TimerCircularDisplay extends StatelessWidget {
  final bool isLargeScreen;
  final bool isLandscape;
  final bool isRunning;
  final TimerMode currentMode;
  final int secondsRemaining;
  final int focusDuration;
  final int breakDuration;
  final int completedSessions;
  final VoidCallback onTimerTapped;

  const TimerCircularDisplay({
    super.key,
    required this.isLargeScreen,
    required this.isLandscape,
    required this.isRunning,
    required this.currentMode,
    required this.secondsRemaining,
    required this.focusDuration,
    required this.breakDuration,
    required this.completedSessions,
    required this.onTimerTapped,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final timerSize = isLandscape
        ? 180.0
        : (isLargeScreen ? AppConstants.timerSizeLarge : AppConstants.timerSizeSmall);
    final fontSize = isLandscape
        ? 48.0
        : (isLargeScreen ? AppConstants.timerFontSizeLarge : AppConstants.timerFontSizeSmall);

    final totalDuration = currentMode == TimerMode.focus ? focusDuration : breakDuration;
    final progress = 1 - (secondsRemaining / totalDuration);

    return GestureDetector(
      onTap: isRunning ? null : onTimerTapped,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: timerSize,
            height: timerSize,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
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
                (currentMode == TimerMode.focus ? l10n.focus : l10n.breakLabel)
                    .toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              TimerDisplay(
                seconds: secondsRemaining,
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
                  l10n.sessionCount(completedSessions),
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
}
