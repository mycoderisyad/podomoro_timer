import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';
import 'package:podomoro_timer/features/music/domain/music_track.dart';
import 'package:podomoro_timer/l10n/l10n.dart';

class MusicPlayerSection extends StatelessWidget {
  final List<MusicTrack> musicQueue;
  final int currentQueueIndex;
  final bool isMusicPlaying;
  final bool isRunning;
  final bool syncMusicWithTimer;
  final double defaultVolume;
  final Duration playbackPosition;
  final Duration trackDuration;
  final VoidCallback onShowQueue;
  final VoidCallback onNavigateToMusicSelection;
  final VoidCallback onPlayPrevious;
  final VoidCallback onPlayNext;
  final ValueChanged<bool>? onSyncChanged;
  final Function(int) onJumpToTrack;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<Duration> onSeek;

  const MusicPlayerSection({
    super.key,
    required this.musicQueue,
    required this.currentQueueIndex,
    required this.isMusicPlaying,
    required this.isRunning,
    required this.syncMusicWithTimer,
    required this.defaultVolume,
    required this.playbackPosition,
    required this.trackDuration,
    required this.onShowQueue,
    required this.onNavigateToMusicSelection,
    required this.onPlayPrevious,
    required this.onPlayNext,
    required this.onSyncChanged,
    required this.onJumpToTrack,
    required this.onVolumeChanged,
    required this.onSeek,
  });

  IconData _volumeIcon(double volume) {
    if (volume == 0) {
      return Icons.volume_off_rounded;
    }
    if (volume < 0.5) {
      return Icons.volume_down_rounded;
    }
    return Icons.volume_up_rounded;
  }

  String _formatDuration(Duration value) {
    final totalSeconds = value.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _showVolumeSheet(BuildContext context) async {
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);
    double volume = defaultVolume;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(dimens.radiusXL),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  dimens.spacingL,
                  dimens.spacingL,
                  dimens.spacingL,
                  dimens.spacingXXL,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.defaultMusicVolume,
                      style: typography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: dimens.spacingM),
                    Row(
                      children: [
                        Icon(
                          _volumeIcon(volume),
                          color: AppColors.primary,
                          size: dimens.iconM,
                        ),
                        SizedBox(width: dimens.spacingS),
                        Expanded(
                          child: Slider(
                            value: volume,
                            onChanged: (value) {
                              setModalState(() => volume = value);
                              onVolumeChanged(value);
                            },
                          ),
                        ),
                        SizedBox(width: dimens.spacingS),
                        Text(
                          '${(volume * 100).round()}%',
                          style: typography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);
    final hasQueue = musicQueue.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: dimens.spacingL,
        vertical: dimens.spacingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: dimens.borderRadiusL,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Softer shadow
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: hasQueue
          ? _buildPlayerState(context, dimens, typography)
          : _buildEmptyState(context, dimens, typography),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppDimens dimens,
    AppTypography typography,
  ) {
    return InkWell(
      onTap: onNavigateToMusicSelection,
      borderRadius: dimens.borderRadiusM,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dimens.spacingS),
        child: Row(
          children: [
            Container(
              height: dimens.musicIconContainer,
              width: dimens.musicIconContainer,
              decoration: BoxDecoration(
                color: AppColors.surfaceAccent,
                borderRadius: dimens.borderRadiusM,
              ),
              child: Icon(
                Icons.library_music_rounded,
                color: AppColors.primary,
                size: dimens.iconM,
              ),
            ),
            SizedBox(width: dimens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.musicL10n.noMusicSelected,
                    style: typography.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    context.musicL10n.tapToSelectMusic,
                    style: typography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerState(
    BuildContext context,
    AppDimens dimens,
    AppTypography typography,
  ) {
    // Failsafe bounds check to guarantee no range error
    final safeIndex =
        currentQueueIndex < musicQueue.length && currentQueueIndex >= 0
        ? currentQueueIndex
        : 0;
    final currentTrack = musicQueue[safeIndex];

    final effectiveDuration = trackDuration > Duration.zero
        ? trackDuration
        : const Duration(seconds: 1);
    final clampedPosition = playbackPosition > effectiveDuration
        ? effectiveDuration
        : playbackPosition;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onNavigateToMusicSelection,
              child: Container(
                height: dimens.musicIconContainer,
                width: dimens.musicIconContainer,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: dimens.borderRadiusM,
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  color: AppColors.primary,
                  size: dimens.iconM,
                ),
              ),
            ),
            SizedBox(width: dimens.spacingM),
            Expanded(
              child: GestureDetector(
                onTap: onNavigateToMusicSelection,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LoopingMarqueeText(
                      text: currentTrack.title,
                      style: typography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      animate: isMusicPlaying,
                    ),
                    Text(
                      '${safeIndex + 1} / ${musicQueue.length}',
                      style: typography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 32, // More compact switch appearance vertically
                  child: Switch(
                    value: syncMusicWithTimer,
                    onChanged: onSyncChanged,
                    activeTrackColor: AppColors.primary,
                  ),
                ),
                Text(
                  'Sync',
                  style: typography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: dimens.spacingM),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: dimens.spacingS,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: dimens.spacingL,
            ),
          ),
          child: Slider(
            value: clampedPosition.inMilliseconds.toDouble(),
            min: 0,
            max: effectiveDuration.inMilliseconds.toDouble(),
            onChanged: trackDuration > Duration.zero
                ? (value) => onSeek(Duration(milliseconds: value.round()))
                : null,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: dimens.spacingXS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(clampedPosition),
                style: typography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatDuration(trackDuration),
                style: typography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => _showVolumeSheet(context),
              icon: Icon(_volumeIcon(defaultVolume)),
              color: AppColors.textSecondary,
              iconSize: dimens.iconM,
              tooltip: context.l10n.defaultMusicVolume,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: isRunning && musicQueue.length > 1
                      ? onPlayPrevious
                      : null,
                  icon: const Icon(Icons.skip_previous_rounded),
                  color: isRunning
                      ? AppColors.textPrimary
                      : AppColors.textSecondary.withValues(alpha: 0.3),
                  iconSize: dimens.iconL,
                ),
                SizedBox(width: dimens.spacingS),
                Container(
                  width: dimens.iconXXL,
                  height: dimens.iconXXL,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isMusicPlaying
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    isMusicPlaying
                        ? Icons.music_note_rounded
                        : Icons.music_off_rounded,
                    color: isMusicPlaying
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                    size: dimens.iconM,
                  ),
                ),
                SizedBox(width: dimens.spacingS),
                IconButton(
                  onPressed: isRunning && musicQueue.length > 1
                      ? onPlayNext
                      : null,
                  icon: const Icon(Icons.skip_next_rounded),
                  color: isRunning
                      ? AppColors.textPrimary
                      : AppColors.textSecondary.withValues(alpha: 0.3),
                  iconSize: dimens.iconL,
                ),
              ],
            ),
            IconButton(
              onPressed: onShowQueue,
              icon: const Icon(Icons.queue_music_rounded),
              color: AppColors.textSecondary,
              iconSize: dimens.iconM,
            ),
          ],
        ),
      ],
    );
  }
}

class _LoopingMarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final bool animate;

  const _LoopingMarqueeText({
    required this.text,
    required this.style,
    required this.animate,
  });

  @override
  State<_LoopingMarqueeText> createState() => _LoopingMarqueeTextState();
}

class _LoopingMarqueeTextState extends State<_LoopingMarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _syncAnimationState();
  }

  @override
  void didUpdateWidget(covariant _LoopingMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate || oldWidget.text != widget.text) {
      _syncAnimationState(reset: oldWidget.text != widget.text);
    }
  }

  void _syncAnimationState({bool reset = false}) {
    if (reset) {
      _controller.reset();
    }

    if (widget.animate) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();

        final textWidth = textPainter.width;
        final availableWidth = constraints.maxWidth;

        if (textWidth <= availableWidth || !widget.animate) {
          return Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        const gap = 32.0;
        final travelWidth = textWidth + gap;

        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final offset = -travelWidth * _controller.value;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: Row(
              children: [
                Text(widget.text, style: widget.style, maxLines: 1),
                const SizedBox(width: gap),
                Text(widget.text, style: widget.style, maxLines: 1),
              ],
            ),
          ),
        );
      },
    );
  }
}
