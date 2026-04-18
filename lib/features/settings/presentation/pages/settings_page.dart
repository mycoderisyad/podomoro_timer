import 'package:flutter/material.dart';

import 'package:podomoro_timer/core/theme/app_colors.dart';
import 'package:podomoro_timer/core/theme/app_dimens.dart';
import 'package:podomoro_timer/core/theme/app_typography.dart';
import 'package:podomoro_timer/features/settings/application/settings_form_controller.dart';
import 'package:podomoro_timer/features/settings/presentation/widgets/audio_settings_section.dart';
import 'package:podomoro_timer/features/settings/presentation/widgets/behavior_settings_section.dart';
import 'package:podomoro_timer/features/settings/presentation/widgets/data_settings_section.dart';
import 'package:podomoro_timer/features/settings/presentation/widgets/language_settings_section.dart';
import 'package:podomoro_timer/features/settings/presentation/widgets/notification_settings_section.dart';
import 'package:podomoro_timer/l10n/features/settings_l10n.dart';
import 'package:podomoro_timer/l10n/l10n.dart';
import 'package:podomoro_timer/shared/services/notification_audio_service.dart';
import 'package:podomoro_timer/shared/settings/app_settings.dart';

class SettingsPage extends StatefulWidget {
  final AppSettings settings;

  const SettingsPage({super.key, required this.settings});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsFormController(
      initialSettings: widget.settings,
      notificationAudioService: AudioPlayerNotificationAudioService(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveSettings() {
    Navigator.pop(context, _controller.buildUpdatedSettings());
  }

  Future<void> _previewSound() async {
    final didPlay = await _controller.playSoundPreview();
    if (!didPlay && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.settingsL10n.notificationPlaybackFailed),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleBackNavigation(bool didPop) async {
    if (didPop) {
      return;
    }

    if (!_controller.hasUnsavedChanges) {
      Navigator.pop(context);
      return;
    }

    final result = await _showUnsavedChangesDialog(context.settingsL10n);
    if (!mounted || result == null || result == 'cancel') {
      return;
    }

    if (result == 'save') {
      _saveSettings();
      return;
    }

    Navigator.pop(context);
  }

  Future<String?> _showUnsavedChangesDialog(SettingsL10n l10n) {
    final dimens = AppDimens.of(context);

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.unsavedChangesTitle),
          content: Text(l10n.unsavedChangesMessage),
          shape: RoundedRectangleBorder(borderRadius: dimens.borderRadiusL),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'discard'),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text(l10n.discardChanges),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'save'),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.settingsL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) => _handleBackNavigation(didPop),
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.textPrimary,
                iconSize: dimens.appBarIconSize,
                onPressed: () => _handleBackNavigation(false),
              ),
              title: Text(l10n.settings, style: typography.titleLarge),
              actions: [
                IconButton(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.check_circle_rounded),
                  color: AppColors.primary,
                  iconSize: dimens.appBarIconSize,
                  tooltip: l10n.saveSettingsTooltip,
                ),
                SizedBox(width: dimens.spacingS),
              ],
            ),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: dimens.maxContentWidth),
                  child: ListView(
                    padding: dimens.pagePadding,
                    children: [
                      SizedBox(height: dimens.spacingS),
                      BehaviorSettingsSection(controller: _controller),
                      SizedBox(height: dimens.spacingXXL),
                      LanguageSettingsSection(controller: _controller),
                      SizedBox(height: dimens.spacingXXL),
                      NotificationSettingsSection(
                        controller: _controller,
                        onPreviewSound: _previewSound,
                      ),
                      SizedBox(height: dimens.spacingXXL),
                      AudioSettingsSection(controller: _controller),
                      SizedBox(height: dimens.spacingXXL),
                      DataSettingsSection(controller: _controller),
                      SizedBox(height: dimens.spacingXXL),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
