import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/music_track.dart';

class MusicQueuePreview extends StatelessWidget {
  final List<MusicTrack> selectedQueue;
  final VoidCallback onClearAll;
  final Function(MusicTrack) onRemoveTrack;

  const MusicQueuePreview({
    super.key,
    required this.selectedQueue,
    required this.onClearAll,
    required this.onRemoveTrack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.musicL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);
    final hasSelection = selectedQueue.isNotEmpty;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: hasSelection
          ? Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(dimens.radiusSheet),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                dimens.spacingL,
                dimens.spacingS,
                dimens.spacingL,
                dimens.spacingL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                              size: dimens.iconS,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: dimens.spacingS),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.playingOrder,
                                style: typography.titleSmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                l10n.selectedTrackCount(selectedQueue.length),
                                style: typography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: onClearAll,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[400],
                          padding: EdgeInsets.symmetric(
                            horizontal: dimens.spacingM,
                            vertical: dimens.spacingS,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: dimens.borderRadiusXL,
                          ),
                          backgroundColor: Colors.red.withValues(alpha: 0.05),
                        ),
                        child: Text(
                          l10n.clearAll,
                          style: typography.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: dimens.spacingS),
                  SizedBox(
                    height: dimens.queuePreviewChipHeight,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedQueue.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: dimens.spacingS),
                      itemBuilder: (context, index) {
                        final track = selectedQueue[index];
                        return Container(
                          padding: EdgeInsets.fromLTRB(
                            dimens.spacingXS,
                            dimens.spacingXS,
                            dimens.spacingM,
                            dimens.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: dimens.borderRadiusXL,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textPrimary.withValues(
                                  alpha: 0.03,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: dimens.trackNumberSize,
                                height: dimens.trackNumberSize,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: typography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: dimens.spacingS),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 120 * dimens.scaleFactor,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      track.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: typography.bodySmall.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: dimens.spacingS),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => onRemoveTrack(track),
                                  borderRadius: dimens.borderRadiusL,
                                  child: Padding(
                                    padding: EdgeInsets.all(dimens.spacingXS),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: dimens.iconS,
                                      color: AppColors.textSecondary.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
