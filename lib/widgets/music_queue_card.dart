import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/l10n.dart';
import '../models/music_track.dart';
import '../utils/localized_music_track_text.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceLight : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          )
        ],
        border: isSelected
            ? Border.all(color: AppColors.textPrimary.withValues(alpha: 0.5), width: 1.5)
            : Border.all(color: Colors.transparent),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon Section
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.secondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSelected ? Icons.check_rounded : Icons.music_note_rounded,
                        color: isSelected ? AppColors.surfaceLight : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    if (queuePosition != null)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surfaceLight, width: 2),
                          ),
                          child: Text(
                            '$queuePosition',
                            style: const TextStyle(
                              color: AppColors.surfaceLight,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Text Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localizedMusicTrackDescription(context, track),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Action Section
                if (isSelected && onRemoveFromQueue != null)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: Colors.redAccent.withValues(alpha: 0.8),
                    onPressed: onRemoveFromQueue,
                    tooltip: context.l10n.removeFromQueueTooltip,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
