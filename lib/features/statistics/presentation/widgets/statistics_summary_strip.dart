import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';

class StatisticsSummaryStrip extends StatelessWidget {
  final List<StatisticsSummaryItem> items;

  const StatisticsSummaryStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items
              .map((item) {
                return Padding(
                  padding: EdgeInsets.only(right: dimens.spacingM),
                  child: SizedBox(width: 150, child: _SummaryTile(item: item)),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}

class StatisticsSummaryItem {
  final String label;
  final String number;
  final String? unit;

  const StatisticsSummaryItem({
    required this.label,
    required this.number,
    this.unit,
  });
}

class _SummaryTile extends StatelessWidget {
  final StatisticsSummaryItem item;

  const _SummaryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: dimens.spacingL,
        vertical: dimens.spacingL,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: dimens.borderRadiusM,
        border: Border.all(color: AppColors.surface, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: typography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: dimens.spacingS),
          _MetricValue(number: item.number, unit: item.unit),
        ],
      ),
    );
  }
}

class _MetricValue extends StatelessWidget {
  final String number;
  final String? unit;

  const _MetricValue({required this.number, this.unit});

  @override
  Widget build(BuildContext context) {
    final typography = AppTypography.of(context);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: number,
            style: typography.titleMedium.copyWith(
              fontSize: typography.sizeXXL,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (unit != null) ...[
            const TextSpan(text: ' '),
            TextSpan(
              text: unit,
              style: typography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
