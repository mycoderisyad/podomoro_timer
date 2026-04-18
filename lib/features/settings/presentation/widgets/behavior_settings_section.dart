import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';
import 'package:podomoro_timer/features/settings/application/settings_form_controller.dart';
import 'package:podomoro_timer/features/settings/presentation/widgets/settings_section_title.dart';
import 'package:podomoro_timer/l10n/features/settings_l10n.dart';
import 'package:podomoro_timer/l10n/l10n.dart';

class BehaviorSettingsSection extends StatelessWidget {
  final SettingsFormController controller;

  const BehaviorSettingsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.settingsL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionTitle(title: l10n.behavior),
        SizedBox(height: dimens.spacingL),
        _SettingsSwitchCard(
          title: l10n.autoStartBreakTitle,
          subtitle: l10n.autoStartBreakSubtitle,
          value: controller.autoStartBreak,
          onChanged: controller.setAutoStartBreak,
        ),
        SizedBox(height: dimens.spacingM),
        _ModeTransitionDelayCard(
          controller: controller,
          l10n: l10n,
          typography: typography,
        ),
        SizedBox(height: dimens.spacingM),
        _SettingsSwitchCard(
          title: l10n.syncMusicWithTimerTitle,
          subtitle: l10n.syncMusicWithTimerSubtitle,
          value: controller.syncMusicWithTimer,
          onChanged: controller.setSyncMusicWithTimer,
        ),
      ],
    );
  }
}

class _SettingsSwitchCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

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
                Text(title, style: typography.titleSmall),
                SizedBox(height: dimens.spacingXS),
                Text(subtitle, style: typography.bodyMedium),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ModeTransitionDelayCard extends StatelessWidget {
  final SettingsFormController controller;
  final SettingsL10n l10n;
  final AppTypography typography;

  const _ModeTransitionDelayCard({
    required this.controller,
    required this.l10n,
    required this.typography,
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
          Text(l10n.modeTransitionDelayTitle, style: typography.titleSmall),
          SizedBox(height: dimens.spacingXS),
          Text(l10n.modeTransitionDelaySubtitle, style: typography.bodyMedium),
          SizedBox(height: dimens.spacingM),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: AppColors.textPrimary,
                size: dimens.iconM,
              ),
              Expanded(
                child: Slider(
                  value: controller.modeTransitionDelaySeconds.toDouble(),
                  min: 0,
                  max: 15,
                  divisions: 15,
                  label: l10n.modeTransitionDelayValue(
                    controller.modeTransitionDelaySeconds,
                  ),
                  onChanged: (value) {
                    controller.setModeTransitionDelaySeconds(value.round());
                  },
                ),
              ),
              Text(
                l10n.modeTransitionDelayValue(
                  controller.modeTransitionDelaySeconds,
                ),
                style: typography.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
