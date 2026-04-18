import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';
import 'package:podomoro_timer/features/settings/application/settings_form_controller.dart';
import 'package:podomoro_timer/features/settings/presentation/widgets/settings_section_title.dart';
import 'package:podomoro_timer/l10n/l10n.dart';

class AudioSettingsSection extends StatelessWidget {
  final SettingsFormController controller;

  const AudioSettingsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.settingsL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);
    final volume = controller.defaultVolume;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionTitle(title: l10n.audio),
        SizedBox(height: dimens.spacingL),
        Container(
          padding: dimens.paddingAllL,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: dimens.borderRadiusM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.defaultMusicVolume, style: typography.titleSmall),
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
                      onChanged: controller.setDefaultVolume,
                    ),
                  ),
                  Text(
                    '${(volume * 100).round()}%',
                    style: typography.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
