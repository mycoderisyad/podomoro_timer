import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';
import 'package:podomoro_timer/features/statistics/application/statistics_view_controller.dart';
import 'package:podomoro_timer/features/statistics/presentation/widgets/statistics_category_chart_card.dart';
import 'package:podomoro_timer/features/statistics/presentation/widgets/statistics_period_selector.dart';
import 'package:podomoro_timer/features/statistics/presentation/widgets/statistics_summary_strip.dart';
import 'package:podomoro_timer/features/statistics/presentation/widgets/statistics_time_chart_card.dart';
import 'package:podomoro_timer/l10n/l10n.dart';
import 'package:podomoro_timer/shared/statistics/statistics_repository.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late final StatisticsViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StatisticsViewController(
      statisticsRepository: SharedPreferencesStatisticsRepository(),
    );
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showClearConfirmation() async {
    final l10n = context.statisticsL10n;
    final dimens = AppDimens.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAllDataTitle),
        content: Text(l10n.deleteAllDataMessage),
        shape: RoundedRectangleBorder(borderRadius: dimens.borderRadiusL),
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
      await _controller.clearAllRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.statisticsL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);
    final minuteUnitLabel = context.l10n.isEnglish ? 'min' : 'menit';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final chartData = _controller.buildTimeChartData(
          l10n.localeName,
          todayLabel: l10n.today,
        );
        final categoryData = _controller.categorySummaries(
          l10n.uncategorizedCategory,
        );
        final mobileCardWidth = MediaQuery.of(context).size.width * 0.85;

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
              iconSize: dimens.appBarIconSize,
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(l10n.statistics, style: typography.titleLarge),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: Colors.redAccent,
                iconSize: dimens.appBarIconSize,
                tooltip: l10n.deleteAllStatisticsTooltip,
                onPressed: _showClearConfirmation,
              ),
              SizedBox(width: dimens.spacingS),
            ],
          ),
          body: SafeArea(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 840;

                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWide ? 980 : dimens.maxContentWidth,
                          ),
                          child: ListView(
                            padding: dimens.pagePadding,
                            children: [
                              StatisticsPeriodSelector(
                                selectedPeriod: _controller.selectedPeriod,
                                onSelected: _controller.setSelectedPeriod,
                              ),
                              SizedBox(height: dimens.spacingL),
                              StatisticsSummaryStrip(
                                items: [
                                  StatisticsSummaryItem(
                                    label: l10n.sessions,
                                    number: '${_controller.totalSessions}',
                                  ),
                                  StatisticsSummaryItem(
                                    label: l10n.totalFocusTime,
                                    number: '${_controller.totalFocusMinutes}',
                                    unit: minuteUnitLabel,
                                  ),
                                  StatisticsSummaryItem(
                                    label: l10n.totalBreakTime,
                                    number: '${_controller.totalBreakMinutes}',
                                    unit: minuteUnitLabel,
                                  ),
                                  StatisticsSummaryItem(
                                    label: l10n.averageFocusPerDay,
                                    number: _controller.averageFocusPerDay
                                        .toStringAsFixed(0),
                                    unit: minuteUnitLabel,
                                  ),
                                  StatisticsSummaryItem(
                                    label: l10n.averageBreakPerDay,
                                    number: _controller.averageBreakPerDay
                                        .toStringAsFixed(0),
                                    unit: minuteUnitLabel,
                                  ),
                                ],
                              ),
                              SizedBox(height: dimens.spacingL),
                              if (isWide)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: StatisticsTimeChartCard(
                                        title: l10n.focusMinutesChartTitle,
                                        chartData: chartData,
                                        barWidth: _controller.resolveBarWidth(
                                          dimens.chartBarWidth,
                                        ),
                                        maxY: _controller.chartMaxY(chartData),
                                        interval: _controller.chartInterval(
                                          chartData,
                                        ),
                                        selectedPeriod:
                                            _controller.selectedPeriod,
                                        minuteUnitLabel: minuteUnitLabel,
                                        emptyLabel: l10n.noDataYet,
                                      ),
                                    ),
                                    SizedBox(width: dimens.spacingL),
                                    Expanded(
                                      child: StatisticsCategoryChartCard(
                                        title: l10n.categoryOverview,
                                        categories: categoryData,
                                        minuteUnitLabel: minuteUnitLabel,
                                        emptyLabel: l10n.noCategoryData,
                                        sessionsLabel: l10n.sessions,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: mobileCardWidth < 300
                                            ? 300
                                            : mobileCardWidth,
                                        child: StatisticsTimeChartCard(
                                          title: l10n.focusMinutesChartTitle,
                                          chartData: chartData,
                                          barWidth: _controller.resolveBarWidth(
                                            dimens.chartBarWidth,
                                          ),
                                          maxY: _controller.chartMaxY(
                                            chartData,
                                          ),
                                          interval: _controller.chartInterval(
                                            chartData,
                                          ),
                                          selectedPeriod:
                                              _controller.selectedPeriod,
                                          minuteUnitLabel: minuteUnitLabel,
                                          emptyLabel: l10n.noDataYet,
                                        ),
                                      ),
                                      SizedBox(width: dimens.spacingL),
                                      SizedBox(
                                        width: mobileCardWidth < 300
                                            ? 300
                                            : mobileCardWidth,
                                        child: StatisticsCategoryChartCard(
                                          title: l10n.categoryOverview,
                                          categories: categoryData,
                                          minuteUnitLabel: minuteUnitLabel,
                                          emptyLabel: l10n.noCategoryData,
                                          sessionsLabel: l10n.sessions,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
