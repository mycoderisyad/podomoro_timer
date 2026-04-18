import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:podomoro_timer/features/statistics/application/statistics_view_controller.dart';
import 'package:podomoro_timer/shared/statistics/focus_session_record.dart';
import 'package:podomoro_timer/shared/statistics/statistic_record.dart';
import 'package:podomoro_timer/shared/statistics/statistics_repository.dart';

void main() {
  group('StatisticsViewController', () {
    setUpAll(() async {
      await initializeDateFormatting('en');
    });

    test('filters records by selected period and groups categories', () async {
      final controller = StatisticsViewController(
        statisticsRepository: _FakeStatisticsRepository([
          StatisticRecord(
            date: DateTime(2026, 4, 18),
            focusSeconds: 1800,
            breakSeconds: 300,
            completedSessions: 1,
            focusSessions: [
              FocusSessionRecord(
                displayName: 'Math',
                customCategoryName: 'Study',
                durationSeconds: 1800,
                completedAt: DateTime(2026, 4, 18, 8),
              ),
            ],
          ),
          StatisticRecord(
            date: DateTime(2026, 4, 16),
            focusSeconds: 1200,
            breakSeconds: 300,
            completedSessions: 1,
            focusSessions: [
              FocusSessionRecord(
                displayName: 'Inbox',
                customCategoryName: 'Admin',
                durationSeconds: 1200,
                completedAt: DateTime(2026, 4, 16, 9),
              ),
            ],
          ),
        ]),
        now: () => DateTime(2026, 4, 18, 9),
      );

      await controller.initialize();

      expect(controller.totalFocusMinutes, 30);

      controller.setSelectedPeriod(StatsPeriod.weekly);

      expect(controller.totalFocusMinutes, 50);

      final summaries = controller.categorySummaries('Uncategorized');
      expect(summaries.map((item) => item.label), ['Study', 'Admin']);
      expect(
        controller.buildTimeChartData('en', todayLabel: 'Today'),
        hasLength(7),
      );
    });
  });
}

class _FakeStatisticsRepository implements StatisticsRepository {
  final List<StatisticRecord> _records;

  _FakeStatisticsRepository(this._records);

  @override
  Future<void> addOrUpdateToday({
    int focusSeconds = 0,
    int breakSeconds = 0,
    int completedSessions = 0,
    FocusSessionRecord? focusSession,
  }) async {}

  @override
  Future<void> clearAllRecords() async {
    _records.clear();
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

  @override
  Future<List<StatisticRecord>> loadRecords() async => List.of(_records);

  @override
  Future<void> runAutoClearIfNeeded(String schedule) async {}

  @override
  Future<void> saveRecords(List<StatisticRecord> records) async {}
}
