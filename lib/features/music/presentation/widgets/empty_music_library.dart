import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';

class EmptyMusicLibrary extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final IconData actionIcon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const EmptyMusicLibrary({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionIcon = Icons.refresh_rounded,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: dimens.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(dimens.spacingXXL),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                icon,
                size: dimens.iconHero,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: dimens.spacingXXL),
            Text(
              title,
              style: typography.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: dimens.spacingS),
            Text(
              message,
              style: typography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              SizedBox(height: dimens.spacingXL),
              FilledButton.icon(
                onPressed: onActionPressed,
                icon: Icon(actionIcon),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: AppColors.surfaceLight,
                ),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
