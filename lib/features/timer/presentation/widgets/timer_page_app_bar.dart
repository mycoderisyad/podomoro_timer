import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';
import 'package:podomoro_timer/l10n/l10n.dart';

class TimerPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenStatistics;
  final VoidCallback onOpenSettings;

  const TimerPageAppBar({
    super.key,
    required this.onOpenStatistics,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.timerL10n;
    final dimens = AppDimens.of(context);

    return AppBar(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Text(
        'P O M O D O R O',
        style: AppTypography.of(
          context,
        ).bodyLarge.copyWith(fontWeight: FontWeight.bold, letterSpacing: 4),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bar_chart_rounded),
          color: AppColors.textPrimary,
          iconSize: dimens.appBarIconSize,
          onPressed: onOpenStatistics,
          tooltip: l10n.statisticsTooltip,
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          color: AppColors.textPrimary,
          iconSize: dimens.appBarIconSize,
          onPressed: onOpenSettings,
          tooltip: l10n.settingsTooltip,
        ),
        SizedBox(width: dimens.spacingS),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
