import 'package:podomoro_timer/shared/statistics/focus_session_record.dart';

class StatisticRecord {
  final DateTime date;
  final int focusSeconds;
  final int breakSeconds;
  final int completedSessions;
  final List<FocusSessionRecord> focusSessions;

  const StatisticRecord({
    required this.date,
    this.focusSeconds = 0,
    this.breakSeconds = 0,
    this.completedSessions = 0,
    this.focusSessions = const [],
  });

  int get focusMinutes => focusSeconds ~/ 60;
  int get breakMinutes => breakSeconds ~/ 60;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'focusSeconds': focusSeconds,
      'breakSeconds': breakSeconds,
      'completedSessions': completedSessions,
      'focusSessions': focusSessions
          .map((session) => session.toJson())
          .toList(growable: false),
    };
  }

  factory StatisticRecord.fromJson(Map<String, dynamic> json) {
    final rawSessions = json['focusSessions'];
    final focusSessions = rawSessions is List
        ? rawSessions
              .whereType<Map>()
              .map(
                (session) => FocusSessionRecord.fromJson(
                  Map<String, dynamic>.from(session),
                ),
              )
              .toList(growable: false)
        : const <FocusSessionRecord>[];

    return StatisticRecord(
      date: DateTime.parse(json['date'] as String),
      focusSeconds: json['focusSeconds'] as int? ?? 0,
      breakSeconds: json['breakSeconds'] as int? ?? 0,
      completedSessions: json['completedSessions'] as int? ?? 0,
      focusSessions: focusSessions,
    );
  }

  StatisticRecord copyWith({
    DateTime? date,
    int? focusSeconds,
    int? breakSeconds,
    int? completedSessions,
    List<FocusSessionRecord>? focusSessions,
  }) {
    return StatisticRecord(
      date: date ?? this.date,
      focusSeconds: focusSeconds ?? this.focusSeconds,
      breakSeconds: breakSeconds ?? this.breakSeconds,
      completedSessions: completedSessions ?? this.completedSessions,
      focusSessions: focusSessions ?? this.focusSessions,
    );
  }
}
