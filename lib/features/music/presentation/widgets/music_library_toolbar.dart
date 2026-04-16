import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/l10n.dart';

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Search and filters only affect the device library list.
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.searchMusicHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: onClearSearch,
                      icon: const Icon(Icons.close_rounded),
                      tooltip: l10n.clearSearchTooltip,
                    ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            key: ValueKey(selectedFileType),
            initialValue: selectedFileType,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n.allAudioTypes),
              ),
              ...availableFileTypes.map((fileType) {
                return DropdownMenuItem<String?>(
                  value: fileType,
                  child: Text(l10n.audioTypeLabel(fileType)),
                );
              }),
            ],
            onChanged: onFileTypeChanged,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                l10n.filteredTrackCount(
                  filteredTrackCount,
                  currentPage,
                  totalPages,
                ),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
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
                ),
                label: Text(
                  areAllVisibleTracksSelected
                      ? l10n.unselectAll
                      : l10n.selectAll,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
