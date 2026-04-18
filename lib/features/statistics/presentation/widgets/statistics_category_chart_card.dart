import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';
import 'package:podomoro_timer/features/statistics/application/statistics_view_controller.dart';
import 'package:podomoro_timer/features/statistics/presentation/widgets/statistics_section_card.dart';

class StatisticsCategoryChartCard extends StatelessWidget {
  final String title;
  final List<StatisticsCategorySummary> categories;
  final String minuteUnitLabel;
  final String emptyLabel;
  final String sessionsLabel;

  const StatisticsCategoryChartCard({
    super.key,
    required this.title,
    required this.categories,
    required this.minuteUnitLabel,
    required this.emptyLabel,
    required this.sessionsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);
    final viewportWidth = MediaQuery.sizeOf(context).width;

    return StatisticsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: typography.titleSmall),
          SizedBox(height: dimens.spacingL),
          if (categories.isEmpty)
            Text(emptyLabel, style: typography.bodyMedium)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final minChartWidth = constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : viewportWidth;
                final chartWidth = math.max(
                  minChartWidth,
                  categories.length * 70.0,
                );

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    height: dimens.chartHeight,
                    width: chartWidth,
                    child: _CategoryChart(
                      categories: categories,
                      minuteUnitLabel: minuteUnitLabel,
                      sessionsLabel: sessionsLabel,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final List<StatisticsCategorySummary> categories;
  final String minuteUnitLabel;
  final String sessionsLabel;

  const _CategoryChart({
    required this.categories,
    required this.minuteUnitLabel,
    required this.sessionsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);
    final maxMinutes = categories.fold<int>(
      0,
      (max, item) => item.totalMinutes > max ? item.totalMinutes : max,
    );
    final maxY = math.max(10.0, (maxMinutes * 1.3).ceilToDouble());

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.textPrimary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} $minuteUnitLabel\n',
                typography.bodySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text:
                        '${categories[groupIndex].sessionsCount} ${sessionsLabel.toLowerCase()}',
                    style: typography.labelSmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
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
                if (index < 0 || index >= categories.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  angle: -0.6,
                  child: Text(
                    categories[index].label,
                    style: typography.labelSmall.copyWith(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: math.max(1, (maxY / 4).ceilToDouble()),
          getDrawingHorizontalLine: (value) =>
              FlLine(color: AppColors.surface, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: categories
            .asMap()
            .entries
            .map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.totalMinutes.toDouble(),
                    color: AppColors.primary,
                    width: dimens.chartBarWidth,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                  ),
                ],
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
