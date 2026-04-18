import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';
import 'package:podomoro_timer/features/settings/application/settings_form_controller.dart';
import 'package:podomoro_timer/features/settings/presentation/widgets/settings_section_title.dart';
import 'package:podomoro_timer/l10n/l10n.dart';

class LanguageSettingsSection extends StatelessWidget {
  final SettingsFormController controller;

  const LanguageSettingsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.settingsL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionTitle(title: l10n.language),
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
              Text(l10n.language, style: typography.titleSmall),
              SizedBox(height: dimens.spacingXS),
              Text(l10n.languageSubtitle, style: typography.bodyMedium),
              SizedBox(height: dimens.spacingM),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.languageCode,
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.textSecondary,
                    size: dimens.iconM,
                  ),
                  items: SettingsFormController.languageOptions
                      .map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            l10n.languageLabel(value),
                            style: typography.bodyLarge,
                          ),
                        );
                      })
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      controller.setLanguageCode(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
