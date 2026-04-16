import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: currentPage > 1 ? onPreviousPage : null,
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: l10n.previousPage,
          ),
          Expanded(
            child: Text(
              l10n.pageIndicator(currentPage, totalPages),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: currentPage < totalPages ? onNextPage : null,
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: l10n.nextPage,
          ),
        ],
      ),
    );
  }
}
