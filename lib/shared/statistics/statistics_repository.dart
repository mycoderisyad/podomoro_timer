import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:podomoro_timer/shared/statistics/focus_session_record.dart';
import 'package:podomoro_timer/shared/statistics/statistic_record.dart';

abstract interface class StatisticsRepository {
  Future<List<StatisticRecord>> loadRecords();

  Future<void> saveRecords(List<StatisticRecord> records);

  Future<void> addOrUpdateToday({
    int focusSeconds,
    int breakSeconds,
    int completedSessions,
    FocusSessionRecord? focusSession,
  });

  Future<void> clearAllRecords();

  Future<void> runAutoClearIfNeeded(String schedule);

  List<StatisticRecord> filterByRange(
    List<StatisticRecord> records,
    DateTime start,
    DateTime end,
  );
}

class SharedPreferencesStatisticsRepository implements StatisticsRepository {
  static const String _storageKey = 'statistics_records';
  static const String _lastClearDateKey = 'statistics_last_clear_date';

  final DateTime Function() _now;

  SharedPreferencesStatisticsRepository({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  @override
  Future<List<StatisticRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return const [];
    }

    final jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map(
          (entry) =>
              StatisticRecord.fromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveRecords(List<StatisticRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((record) => record.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  @override
  Future<void> addOrUpdateToday({
    int focusSeconds = 0,
    int breakSeconds = 0,
    int completedSessions = 0,
    FocusSessionRecord? focusSession,
  }) async {
    final records = List<StatisticRecord>.from(await loadRecords());
    final today = _dateOnly(_now());
    final existingIndex = records.indexWhere(
      (record) => _isSameDay(record.date, today),
    );

    if (existingIndex >= 0) {
      final existing = records[existingIndex];
      records[existingIndex] = existing.copyWith(
        focusSeconds: existing.focusSeconds + focusSeconds,
        breakSeconds: existing.breakSeconds + breakSeconds,
        completedSessions: existing.completedSessions + completedSessions,
        focusSessions: [
          ...existing.focusSessions,
          if (focusSession != null) focusSession,
        ],
      );
    } else {
      records.add(
        StatisticRecord(
          date: today,
          focusSeconds: focusSeconds,
          breakSeconds: breakSeconds,
          completedSessions: completedSessions,
          focusSessions: focusSession == null ? const [] : [focusSession],
        ),
      );
    }

    await saveRecords(records);
  }

  @override
  Future<void> clearAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await prefs.setString(_lastClearDateKey, _now().toIso8601String());
  }

  @override
  Future<void> runAutoClearIfNeeded(String schedule) async {
    if (schedule == 'never') {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastClearString = prefs.getString(_lastClearDateKey);
    final lastClear = lastClearString != null
        ? DateTime.parse(lastClearString)
        : _now();
    final diff = _now().difference(lastClear);

    final shouldClear = switch (schedule) {
      '7_days' => diff.inDays >= 7,
      '30_days' => diff.inDays >= 30,
      '3_months' => diff.inDays >= 90,
      '1_year' => diff.inDays >= 365,
      _ => false,
    };

    if (shouldClear) {
      await clearAllRecords();
    }
  }

  @override
  List<StatisticRecord> filterByRange(
    List<StatisticRecord> records,
    DateTime start,
    DateTime end,
  ) {
    return records
        .where(
          (record) => !record.date.isBefore(start) && !record.date.isAfter(end),
        )
        .toList(growable: false);
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
