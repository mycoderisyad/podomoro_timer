import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/features/timer/domain/timer_mode.dart';
import 'package:podomoro_timer/features/timer/presentation/widgets/action_button.dart';
import 'package:podomoro_timer/l10n/l10n.dart';

class TimerControls extends StatelessWidget {
  final bool isRunning;
  final TimerMode currentMode;
  final VoidCallback onStartPause;
  final VoidCallback onReset;
  final VoidCallback onSwitchMode;

  const TimerControls({
    super.key,
    required this.isRunning,
    required this.currentMode,
    required this.onStartPause,
    required this.onReset,
    required this.onSwitchMode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.timerL10n;
    final dimens = AppDimens.of(context);
    final targetMode = currentMode.isFocus ? l10n.breakLabel : l10n.focus;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: isRunning
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                label: isRunning ? l10n.pause : l10n.start,
                onPressed: onStartPause,
                isPrimary: true,
              ),
            ),
            SizedBox(width: dimens.spacingM),
            Expanded(
              child: ActionButton(
                icon: Icons.refresh_rounded,
                label: l10n.reset,
                onPressed: onReset,
                isPrimary: false,
              ),
            ),
          ],
        ),
        SizedBox(height: dimens.spacingL),
        SizedBox(
          width: double.infinity,
          child: ActionButton(
            icon: Icons.swap_horiz_rounded,
            label: l10n.switchToMode(targetMode),
            onPressed: onSwitchMode,
            isPrimary: false,
            isFullWidth: true,
          ),
        ),
      ],
    );
  }
}
