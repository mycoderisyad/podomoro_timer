import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';
import 'package:podomoro_timer/features/statistics/application/statistics_view_controller.dart';
import 'package:podomoro_timer/l10n/features/statistics_l10n.dart';
import 'package:podomoro_timer/l10n/l10n.dart';

class StatisticsPeriodSelector extends StatelessWidget {
  final StatsPeriod selectedPeriod;
  final ValueChanged<StatsPeriod> onSelected;

  const StatisticsPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.statisticsL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return Container(
      padding: EdgeInsets.all(dimens.spacingXS),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: dimens.borderRadiusM,
      ),
      child: Row(
        children: StatsPeriod.values
            .map((period) {
              final isSelected = selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(period),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(vertical: dimens.spacingM),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.transparent,
                      borderRadius: dimens.borderRadiusS,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _labelForPeriod(l10n, period),
                      style: typography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }

  String _labelForPeriod(StatisticsL10n l10n, StatsPeriod period) {
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
}
