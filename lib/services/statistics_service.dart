import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/statistic_record.dart';

class StatisticsService {
  static const String _storageKey = 'statistics_records';
  static const String _lastClearDateKey = 'statistics_last_clear_date';

  static Future<List<StatisticRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => StatisticRecord.fromJson(e)).toList();
  }

  static Future<void> saveRecords(List<StatisticRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((r) => r.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  static Future<void> addOrUpdateToday({
    int focusSeconds = 0,
    int breakSeconds = 0,
    int completedSessions = 0,
  }) async {
    final records = await loadRecords();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    final existingIndex = records.indexWhere((r) {
      final d = r.date;
      return d.year == todayKey.year &&
          d.month == todayKey.month &&
          d.day == todayKey.day;
    });

    if (existingIndex >= 0) {
      final existing = records[existingIndex];
      records[existingIndex] = existing.copyWith(
        focusSeconds: existing.focusSeconds + focusSeconds,
        breakSeconds: existing.breakSeconds + breakSeconds,
        completedSessions: existing.completedSessions + completedSessions,
      );
    } else {
      records.add(
        StatisticRecord(
          date: todayKey,
          focusSeconds: focusSeconds,
          breakSeconds: breakSeconds,
          completedSessions: completedSessions,
        ),
      );
    }

    await saveRecords(records);
  }

  static Future<void> clearAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await prefs.setString(_lastClearDateKey, DateTime.now().toIso8601String());
  }

  static Future<void> runAutoClearIfNeeded(String schedule) async {
    if (schedule == 'never') return;

    final prefs = await SharedPreferences.getInstance();
    final lastClearStr = prefs.getString(_lastClearDateKey);
    final lastClear = lastClearStr != null
        ? DateTime.parse(lastClearStr)
        : DateTime.now();

    final now = DateTime.now();
    final diff = now.difference(lastClear);
    bool shouldClear = false;

    switch (schedule) {
      case '7_days':
        shouldClear = diff.inDays >= 7;
        break;
      case '30_days':
        shouldClear = diff.inDays >= 30;
        break;
      case '3_months':
        shouldClear = diff.inDays >= 90;
        break;
      case '1_year':
        shouldClear = diff.inDays >= 365;
        break;
    }

    if (shouldClear) {
      await clearAllRecords();
    }
  }

  static List<StatisticRecord> filterByRange(
    List<StatisticRecord> records,
    DateTime start,
    DateTime end,
  ) {
    return records.where((r) {
      return !r.date.isBefore(start) && !r.date.isAfter(end);
    }).toList();
  }
}
