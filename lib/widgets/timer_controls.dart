import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/timer_mode.dart';
import 'action_button.dart';

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
    final l10n = context.l10n;
    final targetMode =
        currentMode == TimerMode.focus ? l10n.breakLabel : l10n.focus;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                label: isRunning ? l10n.pause : l10n.start,
                onPressed: onStartPause,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 12),
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
        const SizedBox(height: 16),
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
