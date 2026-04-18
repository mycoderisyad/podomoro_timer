import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';

class StatisticsSectionCard extends StatelessWidget {
  final Widget child;

  const StatisticsSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(dimens.spacingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: dimens.borderRadiusL,
        border: Border.all(color: AppColors.surface, width: 1.2),
      ),
      child: child,
    );
  }
}
