import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:podomoro_timer/shared/statistics/focus_session_record.dart';
import 'package:podomoro_timer/shared/statistics/statistic_record.dart';
import 'package:podomoro_timer/shared/statistics/statistics_repository.dart';

enum StatsPeriod { daily, weekly, monthly, yearly }

class StatisticsChartDatum {
  final String label;
  final int value;

  const StatisticsChartDatum({required this.label, required this.value});
}

class StatisticsCategorySummary {
  final String label;
  final int totalMinutes;
  final int sessionsCount;

  const StatisticsCategorySummary({
    required this.label,
    required this.totalMinutes,
    required this.sessionsCount,
  });

  StatisticsCategorySummary copyWith({
    String? label,
    int? totalMinutes,
    int? sessionsCount,
  }) {
    return StatisticsCategorySummary(
      label: label ?? this.label,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      sessionsCount: sessionsCount ?? this.sessionsCount,
    );
  }
}

class StatisticsViewController extends ChangeNotifier {
  final StatisticsRepository _statisticsRepository;
  final DateTime Function() _now;

  StatsPeriod _selectedPeriod = StatsPeriod.daily;
  List<StatisticRecord> _allRecords = const [];
  bool _isLoading = true;

  StatisticsViewController({
    required StatisticsRepository statisticsRepository,
    DateTime Function()? now,
  }) : _statisticsRepository = statisticsRepository,
       _now = now ?? DateTime.now;

  StatsPeriod get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;
  List<StatisticRecord> get allRecords => _allRecords;

  Future<void> initialize() async {
    final records = await _statisticsRepository.loadRecords();
    _allRecords = records;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearAllRecords() async {
    await _statisticsRepository.clearAllRecords();
    _allRecords = const [];
    notifyListeners();
  }

  void setSelectedPeriod(StatsPeriod period) {
    if (_selectedPeriod == period) {
      return;
    }

    _selectedPeriod = period;
    notifyListeners();
  }

  List<StatisticRecord> get filteredRecords {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    final DateTime start;

    switch (_selectedPeriod) {
      case StatsPeriod.daily:
        start = today;
        break;
      case StatsPeriod.weekly:
        start = today.subtract(const Duration(days: 6));
        break;
      case StatsPeriod.monthly:
        start = today.subtract(const Duration(days: 29));
        break;
      case StatsPeriod.yearly:
        start = DateTime(now.year - 1, now.month, now.day);
        break;
    }

    return _statisticsRepository.filterByRange(
      _allRecords,
      start,
      today.add(const Duration(days: 1)),
    );
  }

  List<FocusSessionRecord> get focusSessions {
    final sessions =
        filteredRecords.expand((record) => record.focusSessions).toList()
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return sessions;
  }

  List<StatisticsCategorySummary> categorySummaries(String uncategorizedLabel) {
    final categories = <String, StatisticsCategorySummary>{};

    for (final session in focusSessions) {
      final label = session.customCategoryName ?? uncategorizedLabel;
      final existing = categories[label];
      if (existing == null) {
        categories[label] = StatisticsCategorySummary(
          label: label,
          totalMinutes: session.durationMinutes,
          sessionsCount: 1,
        );
      } else {
        categories[label] = existing.copyWith(
          totalMinutes: existing.totalMinutes + session.durationMinutes,
          sessionsCount: existing.sessionsCount + 1,
        );
      }
    }

    final result = categories.values.toList()
      ..sort((a, b) {
        final byMinutes = b.totalMinutes.compareTo(a.totalMinutes);
        if (byMinutes != 0) {
          return byMinutes;
        }
        return a.label.compareTo(b.label);
      });
    return result;
  }

  int get totalSessions =>
      filteredRecords.fold(0, (sum, record) => sum + record.completedSessions);

  int get totalFocusMinutes =>
      filteredRecords.fold(0, (sum, record) => sum + record.focusMinutes);

  int get totalBreakMinutes =>
      filteredRecords.fold(0, (sum, record) => sum + record.breakMinutes);

  double get averageFocusPerDay {
    if (filteredRecords.isEmpty) {
      return 0;
    }
    return totalFocusMinutes / filteredRecords.length;
  }

  double get averageBreakPerDay {
    if (filteredRecords.isEmpty) {
      return 0;
    }
    return totalBreakMinutes / filteredRecords.length;
  }

  double resolveBarWidth(double baseWidth) {
    if (_selectedPeriod == StatsPeriod.yearly ||
        _selectedPeriod == StatsPeriod.monthly) {
      return baseWidth * 0.7;
    }
    if (_selectedPeriod == StatsPeriod.daily) {
      return baseWidth * 1.8;
    }
    return baseWidth;
  }

  List<StatisticsChartDatum> buildTimeChartData(
    String localeName, {
    required String todayLabel,
  }) {
    final now = _now();

    switch (_selectedPeriod) {
      case StatsPeriod.daily:
        return _buildDailyData(filteredRecords, now, todayLabel);
      case StatsPeriod.weekly:
        return _buildWeeklyData(filteredRecords, now, localeName);
      case StatsPeriod.monthly:
        return _buildMonthlyData(filteredRecords, now);
      case StatsPeriod.yearly:
        return _buildYearlyData(filteredRecords, now, localeName);
    }
  }

  double chartMaxY(List<StatisticsChartDatum> data) {
    if (data.isEmpty) {
      return 10;
    }

    final maxValue = data.fold<int>(0, (max, item) {
      return item.value > max ? item.value : max;
    });
    return math.max(10, (maxValue * 1.3).ceilToDouble());
  }

  double chartInterval(List<StatisticsChartDatum> data) {
    final maxY = chartMaxY(data);
    if (maxY <= 30) {
      return 10;
    }
    if (maxY <= 60) {
      return 15;
    }
    if (maxY <= 120) {
      return 30;
    }
    return 60;
  }

  List<StatisticsChartDatum> _buildDailyData(
    List<StatisticRecord> records,
    DateTime now,
    String todayLabel,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final todayRecord = records.where(
      (record) =>
          record.date.year == today.year &&
          record.date.month == today.month &&
          record.date.day == today.day,
    );

    if (todayRecord.isEmpty) {
      return const [];
    }

    return [
      StatisticsChartDatum(
        label: todayLabel,
        value: todayRecord.first.focusMinutes,
      ),
    ];
  }

  List<StatisticsChartDatum> _buildWeeklyData(
    List<StatisticRecord> records,
    DateTime now,
    String localeName,
  ) {
    final today = DateTime(now.year, now.month, now.day);

    return List<StatisticsChartDatum>.generate(7, (index) {
      final date = today.subtract(Duration(days: 6 - index));
      final record = records.where(
        (item) =>
            item.date.year == date.year &&
            item.date.month == date.month &&
            item.date.day == date.day,
      );

      return StatisticsChartDatum(
        label: DateFormat('EEE', localeName).format(date).replaceAll('.', ''),
        value: record.isEmpty ? 0 : record.first.focusMinutes,
      );
    }, growable: false);
  }

  List<StatisticsChartDatum> _buildMonthlyData(
    List<StatisticRecord> records,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);

    return List<StatisticsChartDatum>.generate(30, (index) {
      final offset = 29 - index;
      final date = today.subtract(Duration(days: offset));
      final record = records.where(
        (item) =>
            item.date.year == date.year &&
            item.date.month == date.month &&
            item.date.day == date.day,
      );

      return StatisticsChartDatum(
        label: offset % 5 == 0 ? DateFormat('d/M').format(date) : '',
        value: record.isEmpty ? 0 : record.first.focusMinutes,
      );
    }, growable: false);
  }

  List<StatisticsChartDatum> _buildYearlyData(
    List<StatisticRecord> records,
    DateTime now,
    String localeName,
  ) {
    return List<StatisticsChartDatum>.generate(12, (index) {
      var month = now.month - (11 - index);
      var year = now.year;

      while (month <= 0) {
        month += 12;
        year--;
      }

      final monthRecords = records.where(
        (record) => record.date.year == year && record.date.month == month,
      );
      final totalMinutes = monthRecords.fold<int>(
        0,
        (sum, record) => sum + record.focusMinutes,
      );

      return StatisticsChartDatum(
        label: DateFormat('MMM', localeName).format(DateTime(year, month)),
        value: totalMinutes,
      );
    }, growable: false);
  }
}
