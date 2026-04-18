enum TimerUiEventType { focusSessionCompleted, breakCompleted }

class TimerUiEvent {
  final TimerUiEventType type;

  const TimerUiEvent(this.type);
}
