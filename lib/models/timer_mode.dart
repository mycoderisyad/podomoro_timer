import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';

enum TimerMode { focus, break_ }

extension TimerModeExtension on TimerMode {
  int get duration {
    switch (this) {
      case TimerMode.focus:
        return AppConstants.defaultFocusDuration;
      case TimerMode.break_:
        return AppConstants.defaultBreakDuration;
    }
  }

  String get displayName {
    switch (this) {
      case TimerMode.focus:
        return 'Focus Time';
      case TimerMode.break_:
        return 'Break Time';
    }
  }

  Color get color {
    switch (this) {
      case TimerMode.focus:
        return AppColors.primary;
      case TimerMode.break_:
        return AppColors.secondary;
    }
  }
}
