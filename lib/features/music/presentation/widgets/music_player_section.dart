import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/music_track.dart';

class MusicPlayerSection extends StatelessWidget {
  final bool isLargeScreen;
  final List<MusicTrack> musicQueue;
  final int currentQueueIndex;
  final bool isMusicPlaying;
  final bool isRunning;
  final bool syncMusicWithTimer;
  final double defaultVolume;
  final VoidCallback onShowQueue;
  final VoidCallback onNavigateToMusicSelection;
  final VoidCallback onPlayPrevious;
  final VoidCallback onPlayNext;
  final ValueChanged<bool>? onSyncChanged;
  final Function(int) onJumpToTrack;
  final ValueChanged<double> onVolumeChanged;

  const MusicPlayerSection({
    super.key,
    required this.isLargeScreen,
    required this.musicQueue,
    required this.currentQueueIndex,
    required this.isMusicPlaying,
    required this.isRunning,
    required this.syncMusicWithTimer,
    required this.defaultVolume,
    required this.onShowQueue,
    required this.onNavigateToMusicSelection,
    required this.onPlayPrevious,
    required this.onPlayNext,
    required this.onSyncChanged,
    required this.onJumpToTrack,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.musicL10n;
    final hasQueue = musicQueue.isNotEmpty;
    final currentTrack = hasQueue ? musicQueue[currentQueueIndex] : null;

    return Container(
      width: isLargeScreen ? 500 : double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                key: const Key('music_player_select_button'),
                onTap: onNavigateToMusicSelection,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.library_music_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (hasQueue && musicQueue.length > 1)
                IconButton(
                  onPressed: isRunning ? onPlayPrevious : null,
                  icon: const Icon(Icons.skip_previous_rounded),
                  color: isRunning
                      ? AppColors.primary
                      : AppColors.textSecondary.withValues(alpha: 0.3),
                  iconSize: 28,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (hasQueue && musicQueue.length > 1) const SizedBox(width: 4),
              Expanded(
                child: GestureDetector(
                  key: const Key('music_player_track_area'),
                  onTap: onNavigateToMusicSelection,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTrack?.title ?? l10n.noMusicSelected,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        hasQueue
                            ? l10n.queueSummary(
                                currentQueueIndex + 1,
                                musicQueue.length,
                              )
                            : l10n.tapToSelectMusic,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (hasQueue && musicQueue.length > 1) const SizedBox(width: 4),
              if (hasQueue && musicQueue.length > 1)
                IconButton(
                  onPressed: isRunning ? onPlayNext : null,
                  icon: const Icon(Icons.skip_next_rounded),
                  color: isRunning
                      ? AppColors.primary
                      : AppColors.textSecondary.withValues(alpha: 0.3),
                  iconSize: 28,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (hasQueue) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  key: const Key('music_player_queue_button'),
                  onTap: onShowQueue,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.queue_music_rounded,
                          color: AppColors.primary,
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              '${musicQueue.length}',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Switch(
                value: syncMusicWithTimer,
                onChanged: hasQueue ? onSyncChanged : null,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
          if (hasQueue) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: musicQueue.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final isPlaying =
                      index == currentQueueIndex && isMusicPlaying;
                  final isCurrent = index == currentQueueIndex;

                  return GestureDetector(
                    onTap: () => onJumpToTrack(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.primary.withValues(alpha: 0.5)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPlaying)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                size: 14,
                                color: AppColors.white,
                              ),
                            ),
                          Text(
                            '${index + 1}. ${musicQueue[index].title}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isCurrent
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isCurrent
                                  ? AppColors.white
                                  : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.volume_down_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                Expanded(
                  child: Slider(
                    value: defaultVolume,
                    onChanged: onVolumeChanged,
                  ),
                ),
                Text(
                  '${(defaultVolume * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
