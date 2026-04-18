import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:podomoro_timer/shared/statistics/focus_session_record.dart';
import 'package:podomoro_timer/shared/statistics/statistic_record.dart';
import 'package:podomoro_timer/shared/statistics/statistics_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesStatisticsRepository', () {
    late DateTime now;
    late SharedPreferencesStatisticsRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      now = DateTime(2026, 4, 18, 8, 30);
      repository = SharedPreferencesStatisticsRepository(now: () => now);
    });

    test('addOrUpdateToday accumulates focus, break, and sessions', () async {
      await repository.addOrUpdateToday(
        focusSeconds: 1500,
        completedSessions: 1,
        focusSession: FocusSessionRecord(
          displayName: 'Session #1',
          durationSeconds: 1500,
          completedAt: now,
        ),
      );
      await repository.addOrUpdateToday(breakSeconds: 300);

      final records = await repository.loadRecords();

      expect(records, hasLength(1));
      expect(records.first.focusSeconds, 1500);
      expect(records.first.breakSeconds, 300);
      expect(records.first.completedSessions, 1);
      expect(records.first.focusSessions, hasLength(1));
    });

    test('filterByRange returns records inside inclusive bounds', () {
      final records = [
        StatisticRecord(date: DateTime(2026, 4, 10), focusSeconds: 1500),
        StatisticRecord(date: DateTime(2026, 4, 18), focusSeconds: 3000),
      ];

      final filtered = repository.filterByRange(
        records,
        DateTime(2026, 4, 12),
        DateTime(2026, 4, 19),
      );

      expect(filtered, hasLength(1));
      expect(filtered.first.date, DateTime(2026, 4, 18));
    });

    test('runAutoClearIfNeeded clears stale statistics', () async {
      await repository.saveRecords([
        StatisticRecord(date: DateTime(2026, 4, 1), focusSeconds: 1500),
      ]);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        'statistics_last_clear_date',
        DateTime(2026, 4, 1).toIso8601String(),
      );

      await repository.runAutoClearIfNeeded('7_days');

      final records = await repository.loadRecords();
      expect(records, isEmpty);
    });
  });
}
