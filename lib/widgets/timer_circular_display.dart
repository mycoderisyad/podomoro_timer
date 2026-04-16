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
  final String? modeLabelOverride;
  final int secondsRemaining;
  final int focusDuration;
  final int breakDuration;
  final int completedSessions;
  final String? statusText;
  final VoidCallback onTimerTapped;

  const TimerCircularDisplay({
    super.key,
    required this.isLargeScreen,
    required this.isLandscape,
    required this.isRunning,
    required this.currentMode,
    this.modeLabelOverride,
    required this.secondsRemaining,
    required this.focusDuration,
    required this.breakDuration,
    required this.completedSessions,
    this.statusText,
    required this.onTimerTapped,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.timerL10n;
    final timerSize = isLandscape
        ? 180.0
        : (isLargeScreen
              ? AppConstants.timerSizeLarge
              : AppConstants.timerSizeSmall);
    final fontSize = isLandscape
        ? 48.0
        : (isLargeScreen
              ? AppConstants.timerFontSizeLarge
              : AppConstants.timerFontSizeSmall);

    final totalDuration = currentMode == TimerMode.focus
        ? focusDuration
        : breakDuration;
    final progress = 1 - (secondsRemaining / totalDuration);
    final modeLabel =
        modeLabelOverride ??
        (currentMode == TimerMode.focus ? l10n.focus : l10n.breakLabel);

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
                modeLabel.toUpperCase(),
                style: TextStyle(
                  fontSize: statusText != null && statusText!.isNotEmpty
                      ? 13
                      : 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                  color: statusText != null && statusText!.isNotEmpty
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              TimerDisplay(
                seconds: secondsRemaining,
                fontSize: fontSize,
                color: AppColors.textPrimary,
              ),
              if (statusText != null && statusText!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  statusText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
