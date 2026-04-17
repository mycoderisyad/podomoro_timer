import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_typography.dart';
import '../l10n/l10n.dart';
import '../models/timer_mode.dart';
import 'timer_display.dart';

class TimerCircularDisplay extends StatelessWidget {
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
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    final timerSize = dimens.timerSize;
    final fontSize = dimens.timerFontSize;

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
              strokeWidth: dimens.progressStrokeWidth,
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
                style: typography.titleSmall.copyWith(
                  letterSpacing: 3,
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
                SizedBox(height: dimens.spacingS),
                Text(
                  statusText!,
                  textAlign: TextAlign.center,
                  style: typography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: dimens.spacingS),
              ],
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: dimens.spacingM,
                  vertical: dimens.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: dimens.borderRadiusXL,
                ),
                child: Text(
                  l10n.sessionCount(completedSessions),
                  style: typography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
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
