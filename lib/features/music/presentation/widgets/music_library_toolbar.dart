import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';
import 'package:podomoro_timer/l10n/l10n.dart';

class MusicLibraryToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String? selectedFileType;
  final List<String> availableFileTypes;
  final int filteredTrackCount;
  final int currentPage;
  final int totalPages;
  final bool canToggleSelectAll;
  final bool areAllVisibleTracksSelected;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String?> onFileTypeChanged;
  final VoidCallback onToggleSelectAll;

  const MusicLibraryToolbar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedFileType,
    required this.availableFileTypes,
    required this.filteredTrackCount,
    required this.currentPage,
    required this.totalPages,
    required this.canToggleSelectAll,
    required this.areAllVisibleTracksSelected,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFileTypeChanged,
    required this.onToggleSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.musicL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        dimens.spacingL,
        dimens.spacingS,
        dimens.spacingL,
        0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dimens.isLandscape)
            // Landscape: search + dropdown side by side
            Row(
              children: [
                Expanded(child: _buildSearchField(l10n, dimens)),
                SizedBox(width: dimens.spacingS),
                SizedBox(
                  width: 160 * dimens.scaleFactor,
                  child: _buildDropdown(l10n, dimens, typography),
                ),
              ],
            )
          else ...[
            // Portrait: stacked vertically
            _buildSearchField(l10n, dimens),
            SizedBox(height: dimens.spacingS),
            _buildDropdown(l10n, dimens, typography),
          ],
          SizedBox(height: dimens.spacingXS),
          Row(
            children: [
              Text(
                l10n.filteredTrackCount(
                  filteredTrackCount,
                  currentPage,
                  totalPages,
                ),
                style: typography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: canToggleSelectAll ? onToggleSelectAll : null,
                icon: Icon(
                  areAllVisibleTracksSelected
                      ? Icons.remove_done_rounded
                      : Icons.done_all_rounded,
                  size: dimens.iconS,
                ),
                label: Text(
                  areAllVisibleTracksSelected
                      ? l10n.unselectAll
                      : l10n.selectAll,
                  style: typography.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(dynamic l10n, AppDimens dimens) {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: l10n.searchMusicHint,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: dimens.spacingM,
          vertical: dimens.spacingS,
        ),
        prefixIcon: Icon(Icons.search_rounded, size: dimens.iconS),
        suffixIcon: searchQuery.isEmpty
            ? null
            : IconButton(
                onPressed: onClearSearch,
                icon: Icon(Icons.close_rounded, size: dimens.iconS),
                tooltip: l10n.clearSearchTooltip,
              ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: dimens.borderRadiusM,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    dynamic l10n,
    AppDimens dimens,
    AppTypography typography,
  ) {
    return DropdownButtonFormField<String?>(
      key: ValueKey(selectedFileType),
      initialValue: selectedFileType,
      isDense: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: dimens.spacingM,
          vertical: dimens.spacingS,
        ),
        border: OutlineInputBorder(
          borderRadius: dimens.borderRadiusM,
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(l10n.allAudioTypes, style: typography.bodySmall),
        ),
        ...availableFileTypes.map((fileType) {
          return DropdownMenuItem<String?>(
            value: fileType,
            child: Text(
              l10n.audioTypeLabel(fileType),
              style: typography.bodySmall,
            ),
          );
        }),
      ],
      onChanged: onFileTypeChanged,
    );
  }
}
