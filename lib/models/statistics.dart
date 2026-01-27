class Statistics {
  int completedSessions;
  int totalFocusSeconds;
  int totalBreakSeconds;
  DateTime lastResetDate;

  Statistics({
    this.completedSessions = 0,
    this.totalFocusSeconds = 0,
    this.totalBreakSeconds = 0,
    DateTime? lastResetDate,
  }) : lastResetDate = lastResetDate ?? DateTime.now();

  int get totalFocusMinutes => totalFocusSeconds ~/ 60;
  int get totalBreakMinutes => totalBreakSeconds ~/ 60;

  void reset() {
    completedSessions = 0;
    totalFocusSeconds = 0;
    totalBreakSeconds = 0;
    lastResetDate = DateTime.now();
  }

  void checkAndResetDaily() {
    final today = DateTime.now();
    if (lastResetDate.day != today.day ||
        lastResetDate.month != today.month ||
        lastResetDate.year != today.year) {
      reset();
    }
  }
}
