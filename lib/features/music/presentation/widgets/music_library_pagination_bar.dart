import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/l10n.dart';

class MusicLibraryPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  const MusicLibraryPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.musicL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimens.spacingM,
        vertical: dimens.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: dimens.borderRadiusM,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: currentPage > 1 ? onPreviousPage : null,
            icon: Icon(Icons.chevron_left_rounded, size: dimens.iconL),
            tooltip: l10n.previousPage,
          ),
          Expanded(
            child: Text(
              l10n.pageIndicator(currentPage, totalPages),
              textAlign: TextAlign.center,
              style: typography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: currentPage < totalPages ? onNextPage : null,
            icon: Icon(Icons.chevron_right_rounded, size: dimens.iconL),
            tooltip: l10n.nextPage,
          ),
        ],
      ),
    );
  }
}
