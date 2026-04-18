import 'package:podomoro_timer/features/timer/domain/timer_mode.dart';
import 'package:podomoro_timer/shared/settings/app_settings.dart';

class TimerViewState {
  static const Object _sentinel = Object();

  final AppSettings settings;
  final int secondsRemaining;
  final int modeTransitionCountdown;
  final bool isRunning;
  final TimerMode currentMode;
  final TimerMode? pendingMode;
  final bool shouldAutoStartPendingMode;
  final String? nextFocusSessionNameOverride;
  final String? lastCompletedFocusSessionLabel;
  final int completedSessions;
  final int totalFocusSeconds;
  final int totalBreakSeconds;
  final DateTime runtimeStatsDate;

  const TimerViewState({
    required this.settings,
    required this.secondsRemaining,
    required this.modeTransitionCountdown,
    required this.isRunning,
    required this.currentMode,
    required this.pendingMode,
    required this.shouldAutoStartPendingMode,
    required this.nextFocusSessionNameOverride,
    required this.lastCompletedFocusSessionLabel,
    required this.completedSessions,
    required this.totalFocusSeconds,
    required this.totalBreakSeconds,
    required this.runtimeStatsDate,
  });

  factory TimerViewState.initial({
    required AppSettings settings,
    required DateTime now,
  }) {
    return TimerViewState(
      settings: settings,
      secondsRemaining: settings.focusDuration,
      modeTransitionCountdown: 0,
      isRunning: false,
      currentMode: TimerMode.focus,
      pendingMode: null,
      shouldAutoStartPendingMode: false,
      nextFocusSessionNameOverride: null,
      lastCompletedFocusSessionLabel: null,
      completedSessions: 0,
      totalFocusSeconds: 0,
      totalBreakSeconds: 0,
      runtimeStatsDate: DateTime(now.year, now.month, now.day),
    );
  }

  bool get isTransitioningMode => pendingMode != null;

  int get nextSessionNumber => completedSessions + 1;

  TimerViewState copyWith({
    AppSettings? settings,
    int? secondsRemaining,
    int? modeTransitionCountdown,
    bool? isRunning,
    TimerMode? currentMode,
    Object? pendingMode = _sentinel,
    bool? shouldAutoStartPendingMode,
    Object? nextFocusSessionNameOverride = _sentinel,
    Object? lastCompletedFocusSessionLabel = _sentinel,
    int? completedSessions,
    int? totalFocusSeconds,
    int? totalBreakSeconds,
    DateTime? runtimeStatsDate,
  }) {
    return TimerViewState(
      settings: settings ?? this.settings,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      modeTransitionCountdown:
          modeTransitionCountdown ?? this.modeTransitionCountdown,
      isRunning: isRunning ?? this.isRunning,
      currentMode: currentMode ?? this.currentMode,
      pendingMode: identical(pendingMode, _sentinel)
          ? this.pendingMode
          : pendingMode as TimerMode?,
      shouldAutoStartPendingMode:
          shouldAutoStartPendingMode ?? this.shouldAutoStartPendingMode,
      nextFocusSessionNameOverride:
          identical(nextFocusSessionNameOverride, _sentinel)
          ? this.nextFocusSessionNameOverride
          : nextFocusSessionNameOverride as String?,
      lastCompletedFocusSessionLabel:
          identical(lastCompletedFocusSessionLabel, _sentinel)
          ? this.lastCompletedFocusSessionLabel
          : lastCompletedFocusSessionLabel as String?,
      completedSessions: completedSessions ?? this.completedSessions,
      totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
      totalBreakSeconds: totalBreakSeconds ?? this.totalBreakSeconds,
      runtimeStatsDate: runtimeStatsDate ?? this.runtimeStatsDate,
    );
  }
}
