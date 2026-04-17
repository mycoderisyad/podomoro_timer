import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class TimerDisplay extends StatelessWidget {
  final int seconds;
  final double fontSize;
  final Color color;

  const TimerDisplay({
    super.key,
    required this.seconds,
    required this.fontSize,
    this.color = AppColors.textPrimary,
  });

  String get formattedTime {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formattedTime,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.1,
      ),
    );
  }
}
