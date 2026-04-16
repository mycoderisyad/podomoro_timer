import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../application/music_library_controller.dart';
import '../../data/audio_library_repository.dart';
import 'empty_music_library.dart';
import 'music_library_pagination_bar.dart';
import 'music_queue_card.dart';

class MusicLibraryContent extends StatelessWidget {
  final MusicLibraryController controller;
  final bool hasSelection;
  final VoidCallback onRetryPermission;
  final VoidCallback onRefreshLibrary;
  final VoidCallback onClearFilters;

  const MusicLibraryContent({
    super.key,
    required this.controller,
    required this.hasSelection,
    required this.onRetryPermission,
    required this.onRefreshLibrary,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.musicL10n;
    final filteredTracks = controller.filteredTracks;
    final pagedTracks = controller.pagedTracks;

    // Resolve permission and empty states before rendering the paged list.
    return switch (controller.permissionState) {
      MusicLibraryPermissionState.denied => EmptyMusicLibrary(
        icon: Icons.lock_open_rounded,
        title: l10n.audioPermissionTitle,
        message: l10n.audioPermissionSubtitle,
        actionIcon: Icons.lock_open_rounded,
        actionLabel: l10n.allowAudioAccess,
        onActionPressed: onRetryPermission,
      ),
      MusicLibraryPermissionState.permanentlyDenied => EmptyMusicLibrary(
        icon: Icons.settings_rounded,
        title: l10n.audioPermissionPermanentlyDeniedTitle,
        message: l10n.audioPermissionPermanentlyDeniedSubtitle,
        actionIcon: Icons.settings_rounded,
        actionLabel: l10n.openSettings,
        onActionPressed: controller.openSettings,
      ),
      MusicLibraryPermissionState.unsupported => EmptyMusicLibrary(
        icon: Icons.phone_android_rounded,
        title: l10n.androidOnlyMusicLibraryTitle,
        message: l10n.androidOnlyMusicLibrarySubtitle,
      ),
      _ =>
        controller.tracks.isEmpty
            ? EmptyMusicLibrary(
                icon: Icons.music_off_rounded,
                title: l10n.noDeviceMusicTitle,
                message: l10n.noDeviceMusicSubtitle,
                actionIcon: Icons.refresh_rounded,
                actionLabel: l10n.refreshLibrary,
                onActionPressed: onRefreshLibrary,
              )
            : filteredTracks.isEmpty
            ? EmptyMusicLibrary(
                icon: Icons.search_off_rounded,
                title: l10n.noSearchResultsTitle,
                message: l10n.noSearchResultsSubtitle,
                actionIcon: Icons.close_rounded,
                actionLabel: l10n.clearSearch,
                onActionPressed: onClearFilters,
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        hasSelection ? 24 : 20,
                      ),
                      itemCount: pagedTracks.length,
                      itemBuilder: (context, index) {
                        final track = pagedTracks[index];
                        final queuePosition = controller.getQueuePosition(
                          track,
                        );

                        return MusicQueueCard(
                          track: track,
                          onTap: () => controller.toggleTrackInQueue(track),
                          isSelected: queuePosition != null,
                          queuePosition: queuePosition,
                          onRemoveFromQueue: queuePosition != null
                              ? () => controller.removeFromQueue(track)
                              : null,
                        );
                      },
                    ),
                  ),
                  if (controller.hasMultiplePages)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        hasSelection ? 88 : 16,
                      ),
                      child: MusicLibraryPaginationBar(
                        currentPage: controller.currentPage,
                        totalPages: controller.totalPages,
                        onPreviousPage: controller.goToPreviousPage,
                        onNextPage: controller.goToNextPage,
                      ),
                    ),
                ],
              ),
    };
  }
}
