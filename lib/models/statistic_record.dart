class StatisticRecord {
  final DateTime date;
  final int focusSeconds;
  final int breakSeconds;
  final int completedSessions;

  const StatisticRecord({
    required this.date,
    this.focusSeconds = 0,
    this.breakSeconds = 0,
    this.completedSessions = 0,
  });

  int get focusMinutes => focusSeconds ~/ 60;
  int get breakMinutes => breakSeconds ~/ 60;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'focusSeconds': focusSeconds,
      'breakSeconds': breakSeconds,
      'completedSessions': completedSessions,
    };
  }

  factory StatisticRecord.fromJson(Map<String, dynamic> json) {
    return StatisticRecord(
      date: DateTime.parse(json['date']),
      focusSeconds: json['focusSeconds'] ?? 0,
      breakSeconds: json['breakSeconds'] ?? 0,
      completedSessions: json['completedSessions'] ?? 0,
    );
  }

  StatisticRecord copyWith({
    DateTime? date,
    int? focusSeconds,
    int? breakSeconds,
    int? completedSessions,
  }) {
    return StatisticRecord(
      date: date ?? this.date,
      focusSeconds: focusSeconds ?? this.focusSeconds,
      breakSeconds: breakSeconds ?? this.breakSeconds,
      completedSessions: completedSessions ?? this.completedSessions,
    );
  }
}
