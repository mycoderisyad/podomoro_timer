import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/app_typography.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isFullWidth;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isPrimary,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return Material(
      color: isPrimary ? AppColors.primary : AppColors.surface,
      borderRadius: dimens.borderRadiusL,
      child: InkWell(
        onTap: onPressed,
        borderRadius: dimens.borderRadiusL,
        child: Container(
          height: dimens.buttonHeight,
          padding: dimens.paddingHorizontalXL,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary ? AppColors.white : AppColors.textPrimary,
                size: dimens.iconM,
              ),
              SizedBox(width: dimens.spacingS),
              Text(
                label,
                style: typography.buttonMedium.copyWith(
                  color: isPrimary ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
