import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';
import 'package:podomoro_timer/features/settings/application/settings_form_controller.dart';
import 'package:podomoro_timer/features/settings/presentation/widgets/settings_section_title.dart';
import 'package:podomoro_timer/l10n/features/settings_l10n.dart';
import 'package:podomoro_timer/l10n/l10n.dart';

class NotificationSettingsSection extends StatelessWidget {
  final SettingsFormController controller;
  final Future<void> Function() onPreviewSound;

  const NotificationSettingsSection({
    super.key,
    required this.controller,
    required this.onPreviewSound,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.settingsL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionTitle(title: l10n.notifications),
        SizedBox(height: dimens.spacingL),
        _NotificationSwitchCard(controller: controller, l10n: l10n),
        if (controller.soundEnabled) ...[
          SizedBox(height: dimens.spacingM),
          _SoundSelectionCard(
            controller: controller,
            l10n: l10n,
            typography: typography,
            onPreviewSound: onPreviewSound,
          ),
          SizedBox(height: dimens.spacingM),
          _NotificationVolumeCard(
            controller: controller,
            l10n: l10n,
            typography: typography,
            onPreviewSound: onPreviewSound,
          ),
        ],
      ],
    );
  }
}

class _NotificationSwitchCard extends StatelessWidget {
  final SettingsFormController controller;
  final SettingsL10n l10n;

  const _NotificationSwitchCard({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return Container(
      padding: dimens.paddingAllL,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: dimens.borderRadiusM,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.soundNotificationsTitle,
                  style: typography.titleSmall,
                ),
                SizedBox(height: dimens.spacingXS),
                Text(
                  l10n.soundNotificationsSubtitle,
                  style: typography.bodyMedium,
                ),
              ],
            ),
          ),
          Switch(
            value: controller.soundEnabled,
            onChanged: controller.setSoundEnabled,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SoundSelectionCard extends StatelessWidget {
  final SettingsFormController controller;
  final SettingsL10n l10n;
  final AppTypography typography;
  final Future<void> Function() onPreviewSound;

  const _SoundSelectionCard({
    required this.controller,
    required this.l10n,
    required this.typography,
    required this.onPreviewSound,
  });

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);

    return Container(
      padding: dimens.paddingAllL,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: dimens.borderRadiusM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.notificationSound, style: typography.titleSmall),
          SizedBox(height: dimens.spacingM),
          Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.notificationSound,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AppColors.textSecondary,
                      size: dimens.iconM,
                    ),
                    items: SettingsFormController.soundOptions
                        .map((option) {
                          return DropdownMenuItem<String>(
                            value: option['path'],
                            child: Text(
                              l10n.soundLabel(option['id']!),
                              style: typography.bodyLarge,
                            ),
                          );
                        })
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        controller.setNotificationSound(value);
                        onPreviewSound();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: dimens.spacingS),
              IconButton(
                icon: const Icon(Icons.play_circle_fill_rounded),
                color: AppColors.primary,
                iconSize: dimens.iconXL,
                tooltip: l10n.testSoundTooltip,
                onPressed: onPreviewSound,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationVolumeCard extends StatelessWidget {
  final SettingsFormController controller;
  final SettingsL10n l10n;
  final AppTypography typography;
  final Future<void> Function() onPreviewSound;

  const _NotificationVolumeCard({
    required this.controller,
    required this.l10n,
    required this.typography,
    required this.onPreviewSound,
  });

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens.of(context);
    final volume = controller.notificationVolume;

    return Container(
      padding: dimens.paddingAllL,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: dimens.borderRadiusM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.notificationVolume, style: typography.titleSmall),
          SizedBox(height: dimens.spacingM),
          Row(
            children: [
              Icon(
                volume == 0
                    ? Icons.volume_off
                    : volume < 0.5
                    ? Icons.volume_down
                    : Icons.volume_up,
                color: AppColors.textPrimary,
                size: dimens.iconM,
              ),
              Expanded(
                child: Slider(
                  value: volume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: controller.setNotificationVolume,
                  onChangeEnd: (_) => onPreviewSound(),
                ),
              ),
              Text('${(volume * 100).round()}%', style: typography.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
