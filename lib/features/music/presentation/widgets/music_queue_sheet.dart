import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/l10n.dart';
import '../../../../utils/localized_music_track_text.dart';
import '../../domain/music_track.dart';

class MusicQueueSheet extends StatelessWidget {
  final List<MusicTrack> musicQueue;
  final int currentQueueIndex;
  final bool isMusicPlaying;
  final Function(int) onJumpToTrack;

  const MusicQueueSheet({
    super.key,
    required this.musicQueue,
    required this.currentQueueIndex,
    required this.isMusicPlaying,
    required this.onJumpToTrack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.musicL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(dimens.spacingXL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(dimens.spacingS),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.queue_music_rounded,
                          size: dimens.iconM,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: dimens.spacingM),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.musicQueue, style: typography.titleMedium),
                          Text(
                            l10n.trackCount(musicQueue.length),
                            style: typography.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: dimens.spacingL),
                itemCount: musicQueue.length,
                itemBuilder: (context, index) {
                  final track = musicQueue[index];
                  final isCurrentTrack = index == currentQueueIndex;

                  return Padding(
                    padding: EdgeInsets.only(bottom: dimens.spacingS),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          onJumpToTrack(index);
                          Navigator.pop(context);
                        },
                        borderRadius: dimens.borderRadiusM,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: dimens.spacingL,
                            vertical: dimens.spacingM,
                          ),
                          decoration: BoxDecoration(
                            color: isCurrentTrack
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.surface,
                            borderRadius: dimens.borderRadiusM,
                            border: Border.all(
                              color: isCurrentTrack
                                  ? AppColors.primary.withValues(alpha: 0.4)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: dimens.buttonHeightSmall,
                                height: dimens.buttonHeightSmall,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isCurrentTrack
                                      ? AppColors.primary
                                      : AppColors.surfaceLight,
                                  shape: BoxShape.circle,
                                ),
                                child: isCurrentTrack && isMusicPlaying
                                    ? Icon(
                                        Icons.play_arrow_rounded,
                                        size: dimens.iconM,
                                        color: AppColors.white,
                                      )
                                    : Text(
                                        '${index + 1}',
                                        style: typography.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isCurrentTrack
                                              ? AppColors.white
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                              ),
                              SizedBox(width: dimens.spacingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      track.title,
                                      style: isCurrentTrack
                                          ? typography.bodyMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                            )
                                          : typography.bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      localizedMusicTrackDescription(
                                        context,
                                        track,
                                      ),
                                      style: typography.labelSmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (isCurrentTrack)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: dimens.spacingS,
                                    vertical: dimens.spacingXS,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: dimens.borderRadiusS,
                                  ),
                                  child: Text(
                                    l10n.playing,
                                    style: typography.labelSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
