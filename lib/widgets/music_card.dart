import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/music_track.dart';

class MusicCard extends StatelessWidget {
  final MusicTrack track;
  final VoidCallback onTap;
  final bool isSelected;

  const MusicCard({
    super.key,
    required this.track,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isSelected ? Icons.music_note : Icons.music_note_outlined,
            color: AppColors.white,
            size: 24,
          ),
        ),
        title: Text(
          track.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          track.description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 28,
              )
            : null,
      ),
    );
  }
}
