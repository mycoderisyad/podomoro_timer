import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';
import 'package:podomoro_timer/features/music/domain/music_track.dart';
import 'package:podomoro_timer/features/music/presentation/utils/localized_music_track_text.dart';
import 'package:podomoro_timer/l10n/l10n.dart';

class MusicQueueCard extends StatelessWidget {
  final MusicTrack track;
  final VoidCallback onTap;
  final bool isSelected;
  final int? queuePosition;
  final VoidCallback? onRemoveFromQueue;

  const MusicQueueCard({
    super.key,
    required this.track,
    required this.onTap,
    this.isSelected = false,
    this.queuePosition,
    this.onRemoveFromQueue,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.musicL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: dimens.spacingXS,
        horizontal: dimens.spacingS,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceLight : AppColors.surface,
        borderRadius: dimens.borderRadiusM,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isSelected
            ? Border.all(
                color: AppColors.textPrimary.withValues(alpha: 0.5),
                width: 1.5,
              )
            : Border.all(color: Colors.transparent),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: dimens.borderRadiusM,
          child: Padding(
            padding: EdgeInsets.all(dimens.spacingM),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: dimens.buttonHeightSmall,
                      height: dimens.buttonHeightSmall,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.secondary.withValues(alpha: 0.3),
                        borderRadius: dimens.borderRadiusM,
                      ),
                      child: Icon(
                        isSelected
                            ? Icons.check_rounded
                            : Icons.music_note_rounded,
                        color: isSelected
                            ? AppColors.surfaceLight
                            : AppColors.textSecondary,
                        size: dimens.iconM,
                      ),
                    ),
                    if (queuePosition != null)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          width: dimens.spacingXL,
                          height: dimens.spacingXL,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surfaceLight,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '$queuePosition',
                            style: typography.labelSmall.copyWith(
                              color: AppColors.surfaceLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: dimens.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: typography.bodyLarge.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: dimens.spacingXXS),
                      Text(
                        localizedMusicTrackDescription(context, track),
                        style: typography.bodySmall.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected && onRemoveFromQueue != null)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: Colors.redAccent.withValues(alpha: 0.8),
                    onPressed: onRemoveFromQueue,
                    tooltip: l10n.removeFromQueueTooltip,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
