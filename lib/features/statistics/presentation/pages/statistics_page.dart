import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/features/statistics_l10n.dart';
import '../../../../l10n/l10n.dart';
import '../../../../models/statistic_record.dart';
import '../../../../services/statistics_service.dart';

enum StatsPeriod { daily, weekly, monthly, yearly }

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  StatsPeriod _selectedPeriod = StatsPeriod.daily;
  List<StatisticRecord> _allRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await StatisticsService.loadRecords();
    if (mounted) {
      setState(() {
        _allRecords = records;
        _isLoading = false;
      });
    }
  }

  List<StatisticRecord> get _filteredRecords {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime start;

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

    return StatisticsService.filterByRange(
      _allRecords,
      start,
      today.add(const Duration(days: 1)),
    );
  }

  int get _totalSessions =>
      _filteredRecords.fold(0, (sum, r) => sum + r.completedSessions);

  int get _totalFocusMinutes =>
      _filteredRecords.fold(0, (sum, r) => sum + r.focusMinutes);

  double get _avgFocusPerDay {
    if (_filteredRecords.isEmpty) return 0;
    return _totalFocusMinutes / _filteredRecords.length;
  }

  Future<void> _showClearConfirmation() async {
    final l10n = context.statisticsL10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAllDataTitle),
        content: Text(l10n.deleteAllDataMessage),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await StatisticsService.clearAllRecords();
      setState(() => _allRecords = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.statisticsL10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.statistics,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: Colors.redAccent,
            tooltip: l10n.deleteAllStatisticsTooltip,
            onPressed: _showClearConfirmation,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildPeriodSelector(l10n),
                  const SizedBox(height: 20),
                  _buildSummaryCards(l10n),
                  const SizedBox(height: 20),
                  _buildChartSection(l10n),
                ],
              ),
      ),
    );
  }

  Widget _buildPeriodSelector(StatisticsL10n l10n) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: StatsPeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  _periodLabel(l10n, period),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _periodLabel(StatisticsL10n l10n, StatsPeriod period) {
    switch (period) {
      case StatsPeriod.daily:
        return l10n.today;
      case StatsPeriod.weekly:
        return l10n.week;
      case StatsPeriod.monthly:
        return l10n.month;
      case StatsPeriod.yearly:
        return l10n.year;
    }
  }

  Widget _buildSummaryCards(StatisticsL10n l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniCard(
            label: l10n.sessions,
            value: '$_totalSessions',
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMiniCard(
            label: l10n.focus,
            value: l10n.minutesValue(_totalFocusMinutes),
            icon: Icons.timer_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMiniCard(
            label: l10n.average,
            value: l10n.minutesValue(_avgFocusPerDay.toStringAsFixed(0)),
            icon: Icons.trending_up_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surface, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(StatisticsL10n l10n) {
    final chartData = _buildChartData(l10n.localeName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surface, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.focusMinutesChartTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: chartData.isEmpty
                ? Center(
                    child: Text(
                      l10n.noDataYet,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _chartMaxY(chartData),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              l10n.minutesValue(rod.toY.toInt()),
                              const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= chartData.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  chartData[idx]['label'] as String,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _chartInterval(chartData),
                        getDrawingHorizontalLine: (value) =>
                            FlLine(color: AppColors.surface, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: chartData.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: (entry.value['value'] as int).toDouble(),
                              color: AppColors.primary,
                              width: _barWidth,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  double get _barWidth {
    switch (_selectedPeriod) {
      case StatsPeriod.daily:
        return 24;
      case StatsPeriod.weekly:
        return 20;
      case StatsPeriod.monthly:
        return 8;
      case StatsPeriod.yearly:
        return 14;
    }
  }

  double _chartMaxY(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 10;
    final maxVal = data.fold<int>(0, (max, e) {
      final val = e['value'] as int;
      return val > max ? val : max;
    });
    return (maxVal * 1.3).ceilToDouble().clamp(10, double.infinity);
  }

  double _chartInterval(List<Map<String, dynamic>> data) {
    final maxY = _chartMaxY(data);
    if (maxY <= 30) return 10;
    if (maxY <= 60) return 15;
    if (maxY <= 120) return 30;
    return 60;
  }

  List<Map<String, dynamic>> _buildChartData(String localeName) {
    final records = _filteredRecords;
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case StatsPeriod.daily:
        return _buildDailyData(records, now);
      case StatsPeriod.weekly:
        return _buildWeeklyData(records, now, localeName);
      case StatsPeriod.monthly:
        return _buildMonthlyData(records, now);
      case StatsPeriod.yearly:
        return _buildYearlyData(records, now, localeName);
    }
  }

  List<Map<String, dynamic>> _buildDailyData(
    List<StatisticRecord> records,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final todayRecord = records.where(
      (r) =>
          r.date.year == today.year &&
          r.date.month == today.month &&
          r.date.day == today.day,
    );

    if (todayRecord.isEmpty) return [];

    return [
      {
        'label': context.statisticsL10n.today,
        'value': todayRecord.first.focusMinutes,
      },
    ];
  }

  List<Map<String, dynamic>> _buildWeeklyData(
    List<StatisticRecord> records,
    DateTime now,
    String localeName,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final result = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final record = records.where(
        (r) =>
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day,
      );

      result.add({
        'label': DateFormat('EEE', localeName).format(date).replaceAll('.', ''),
        'value': record.isEmpty ? 0 : record.first.focusMinutes,
      });
    }
    return result;
  }

  List<Map<String, dynamic>> _buildMonthlyData(
    List<StatisticRecord> records,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final result = <Map<String, dynamic>>[];

    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final record = records.where(
        (r) =>
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day,
      );

      final label = i % 5 == 0 ? DateFormat('d/M').format(date) : '';
      result.add({
        'label': label,
        'value': record.isEmpty ? 0 : record.first.focusMinutes,
      });
    }
    return result;
  }

  List<Map<String, dynamic>> _buildYearlyData(
    List<StatisticRecord> records,
    DateTime now,
    String localeName,
  ) {
    final result = <Map<String, dynamic>>[];

    for (int i = 11; i >= 0; i--) {
      int month = now.month - i;
      int year = now.year;
      while (month <= 0) {
        month += 12;
        year--;
      }

      final monthRecords = records.where(
        (r) => r.date.year == year && r.date.month == month,
      );
      final totalMinutes = monthRecords.fold<int>(
        0,
        (sum, r) => sum + r.focusMinutes,
      );

      final date = DateTime(year, month);
      result.add({
        'label': DateFormat('MMM', localeName).format(date),
        'value': totalMinutes,
      });
    }
    return result;
  }
}
