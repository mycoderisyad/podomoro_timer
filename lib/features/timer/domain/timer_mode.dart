enum TimerMode { focus, break_ }

extension TimerModeX on TimerMode {
  bool get isFocus => this == TimerMode.focus;

  TimerMode get toggled => isFocus ? TimerMode.break_ : TimerMode.focus;
}
