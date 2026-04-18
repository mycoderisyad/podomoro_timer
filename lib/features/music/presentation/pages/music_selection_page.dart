import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';
import 'package:podomoro_timer/features/music/application/music_library_controller.dart';
import 'package:podomoro_timer/features/music/data/audio_library_repository.dart';
import 'package:podomoro_timer/features/music/domain/music_track.dart';
import 'package:podomoro_timer/features/music/presentation/widgets/music_library_content.dart';
import 'package:podomoro_timer/features/music/presentation/widgets/music_library_toolbar.dart';
import 'package:podomoro_timer/features/music/presentation/widgets/music_queue_preview.dart';
import 'package:podomoro_timer/l10n/l10n.dart';

class MusicSelectionPage extends StatefulWidget {
  final List<MusicTrack>? currentQueue;

  const MusicSelectionPage({super.key, this.currentQueue});

  @override
  State<MusicSelectionPage> createState() => _MusicSelectionPageState();
}

class _MusicSelectionPageState extends State<MusicSelectionPage> {
  late final MusicLibraryController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = MusicLibraryController(
      repository: const MethodChannelAudioLibraryRepository(),
    );
    _controller.initialize(widget.currentQueue ?? const []);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _confirmSelection() {
    Navigator.pop(context, List<MusicTrack>.from(_controller.selectedQueue));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.musicL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final hasSelection = _controller.selectedQueue.isNotEmpty;
        final isCompactActionLayout =
            dimens.isLandscape || dimens.isCompactHeight;
        final actionButtonInset = hasSelection
            ? dimens.buttonHeight +
                  (isCompactActionLayout ? dimens.spacingL : dimens.spacingXXL)
            : 0.0;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) {
              Navigator.of(context).pop(_controller.selectedQueue);
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.textPrimary,
                iconSize: dimens.appBarIconSize,
                onPressed: () =>
                    Navigator.pop(context, _controller.selectedQueue),
              ),
              title: Text(l10n.musicLibrary, style: typography.titleLarge),
              actions: [
                IconButton(
                  onPressed: _controller.isLoading
                      ? null
                      : () => _controller.loadTracks(requestPermission: true),
                  icon: const Icon(Icons.refresh_rounded),
                  color: AppColors.primary,
                  iconSize: dimens.appBarIconSize,
                  tooltip: l10n.refreshLibrary,
                ),
                SizedBox(width: dimens.spacingS),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: hasSelection
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompactActionLayout
                          ? dimens.spacingL
                          : dimens.spacingXL,
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: _confirmSelection,
                      backgroundColor: AppColors.textPrimary,
                      elevation: 4,
                      highlightElevation: 8,
                      extendedPadding: EdgeInsets.symmetric(
                        horizontal: isCompactActionLayout
                            ? dimens.spacingL
                            : dimens.spacingXL,
                      ),
                      extendedIconLabelSpacing: dimens.spacingS,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: dimens.borderRadiusL,
                      ),
                      icon: Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.surfaceLight,
                        size: isCompactActionLayout
                            ? dimens.iconM
                            : dimens.iconL,
                      ),
                      label: Text(
                        l10n.useTracks(_controller.selectedQueue.length),
                        style:
                            (isCompactActionLayout
                                    ? typography.titleSmall
                                    : typography.titleMedium)
                                .copyWith(
                                  color: AppColors.surfaceLight,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  )
                : null,
            body: SafeArea(
              child: _buildBody(
                context,
                hasSelection,
                dimens,
                actionButtonInset,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    bool hasSelection,
    AppDimens dimens,
    double actionButtonInset,
  ) {
    if (_controller.isLoading && _controller.tracks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasLibraryTracks = _controller.tracks.isNotEmpty;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dimens.maxContentWidth),
        child: Column(
          children: [
            // Wrap in Flexible so it can shrink in landscape.
            Flexible(
              flex: 0,
              child: MusicQueuePreview(
                selectedQueue: _controller.selectedQueue,
                onClearAll: _controller.clearQueue,
                onRemoveTrack: _controller.removeFromQueue,
              ),
            ),
            if (hasLibraryTracks)
              Flexible(
                flex: 0,
                child: SingleChildScrollView(
                  child: MusicLibraryToolbar(
                    searchController: _searchController,
                    searchQuery: _controller.searchQuery,
                    selectedFileType: _controller.selectedFileType,
                    availableFileTypes: _controller.availableFileTypes,
                    filteredTrackCount: _controller.filteredTracks.length,
                    currentPage: _controller.currentPage,
                    totalPages: _controller.totalPages,
                    canToggleSelectAll: _controller.hasVisibleTracks,
                    areAllVisibleTracksSelected:
                        _controller.areAllVisibleTracksSelected,
                    onSearchChanged: _controller.setSearchQuery,
                    onClearSearch: _clearSearch,
                    onFileTypeChanged: _controller.setSelectedFileType,
                    onToggleSelectAll: _controller.toggleSelectAllVisibleTracks,
                  ),
                ),
              ),
            Expanded(
              child: MusicLibraryContent(
                controller: _controller,
                hasSelection: hasSelection,
                selectionBottomInset: actionButtonInset,
                onRetryPermission: () =>
                    _controller.loadTracks(requestPermission: true),
                onRefreshLibrary: () =>
                    _controller.loadTracks(requestPermission: false),
                onClearFilters: _clearFilters,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _controller.setSearchQuery('');
  }

  void _clearFilters() {
    _clearSearch();
    _controller.setSelectedFileType(null);
  }
}
