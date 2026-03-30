import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/l10n.dart';

class EmptyMusicLibrary extends StatelessWidget {
  final VoidCallback onImportPressed;

  const EmptyMusicLibrary({
    super.key,
    required this.onImportPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
            ),
            child: Icon(
              Icons.library_music_rounded,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.emptyLibraryTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onImportPressed,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.importMusicFiles),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
