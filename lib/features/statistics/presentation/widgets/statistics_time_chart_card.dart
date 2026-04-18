import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';
import 'package:podomoro_timer/features/statistics/application/statistics_view_controller.dart';
import 'package:podomoro_timer/features/statistics/presentation/widgets/statistics_section_card.dart';

class StatisticsTimeChartCard extends StatelessWidget {
  final String title;
  final List<StatisticsChartDatum> chartData;
  final double barWidth;
  final double maxY;
  final double interval;
  final StatsPeriod selectedPeriod;
  final String minuteUnitLabel;
  final String emptyLabel;

  const StatisticsTimeChartCard({
    super.key,
    required this.title,
    required this.chartData,
    required this.barWidth,
    required this.maxY,
    required this.interval,
    required this.selectedPeriod,
    required this.minuteUnitLabel,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return StatisticsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: typography.titleSmall),
          SizedBox(height: dimens.spacingL),
          SizedBox(
            height: dimens.chartHeight,
            child: chartData.isEmpty
                ? Center(child: Text(emptyLabel, style: typography.bodyMedium))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => AppColors.textPrimary,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.toInt()} $minuteUnitLabel',
                              typography.bodySmall.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
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
                            reservedSize: dimens.spacingXXXL + dimens.spacingS,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: typography.labelSmall,
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: dimens.spacingXXXL + dimens.spacingL,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= chartData.length) {
                                return const SizedBox.shrink();
                              }
                              return SideTitleWidget(
                                meta: meta,
                                angle: selectedPeriod == StatsPeriod.daily
                                    ? 0
                                    : -0.6,
                                child: Text(
                                  chartData[index].label,
                                  style: typography.labelSmall.copyWith(
                                    fontSize: chartData.length > 10 ? 9 : null,
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
                        horizontalInterval: interval,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.surface,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: chartData
                          .asMap()
                          .entries
                          .map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.value.toDouble(),
                                  color: AppColors.primary,
                                  width: barWidth,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(5),
                                  ),
                                ),
                              ],
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
