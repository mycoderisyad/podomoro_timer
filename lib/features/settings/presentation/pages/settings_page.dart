import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/features/settings_l10n.dart';
import '../../../../l10n/l10n.dart';
import '../../../../models/app_settings.dart';
import '../../../../services/notification_audio_service.dart';

class SettingsPage extends StatefulWidget {
  final AppSettings settings;

  const SettingsPage({super.key, required this.settings});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _autoStartBreak;
  late int _modeTransitionDelaySeconds;
  late bool _syncMusicWithTimer;
  late double _defaultVolume;
  late bool _soundEnabled;
  late String _notificationSound;
  late double _notificationVolume;
  late String _autoClearSchedule;
  late String _languageCode;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, String>> _soundOptions = [
    {'id': 'bell', 'path': 'assets/audio/notifications/bell.ogg'},
    {'id': 'chime', 'path': 'assets/audio/notifications/chime.ogg'},
    {'id': 'ding', 'path': 'assets/audio/notifications/ding.ogg'},
  ];

  final List<String> _autoClearOptions = [
    'never',
    '7_days',
    '30_days',
    '3_months',
    '1_year',
  ];

  final List<String> _languageOptions = ['en', 'id'];

  @override
  void initState() {
    super.initState();
    _autoStartBreak = widget.settings.autoStartBreak;
    _modeTransitionDelaySeconds = widget.settings.modeTransitionDelaySeconds;
    _syncMusicWithTimer = widget.settings.syncMusicWithTimer;
    _defaultVolume = widget.settings.defaultVolume;
    _soundEnabled = widget.settings.soundEnabled;
    _notificationSound = widget.settings.notificationSound;
    _notificationVolume = widget.settings.notificationVolume;
    _autoClearSchedule = widget.settings.autoClearSchedule;
    _languageCode = widget.settings.languageCode;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    return _autoStartBreak != widget.settings.autoStartBreak ||
        _modeTransitionDelaySeconds !=
            widget.settings.modeTransitionDelaySeconds ||
        _syncMusicWithTimer != widget.settings.syncMusicWithTimer ||
        _defaultVolume != widget.settings.defaultVolume ||
        _soundEnabled != widget.settings.soundEnabled ||
        _notificationSound != widget.settings.notificationSound ||
        _notificationVolume != widget.settings.notificationVolume ||
        _autoClearSchedule != widget.settings.autoClearSchedule ||
        _languageCode != widget.settings.languageCode;
  }

  void _saveSettings() {
    final updatedSettings = widget.settings.copyWith(
      autoStartBreak: _autoStartBreak,
      modeTransitionDelaySeconds: _modeTransitionDelaySeconds,
      syncMusicWithTimer: _syncMusicWithTimer,
      defaultVolume: _defaultVolume,
      soundEnabled: _soundEnabled,
      notificationSound: _notificationSound,
      notificationVolume: _notificationVolume,
      autoClearSchedule: _autoClearSchedule,
      languageCode: _languageCode,
    );
    Navigator.pop(context, updatedSettings);
  }

  Future<void> _playSoundPreview() async {
    try {
      await NotificationAudioService.playAsset(
        player: _audioPlayer,
        assetPath: _notificationSound,
        volume: _notificationVolume,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.settingsL10n.notificationPlaybackFailed),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleBackNavigation(bool didPop) async {
    if (didPop) return;

    if (!_hasUnsavedChanges) {
      Navigator.pop(context);
      return;
    }

    final l10n = context.settingsL10n;
    final dimens = AppDimens.of(context);
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
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

    if (!mounted || result == null || result == 'cancel') return;

    if (result == 'save') {
      _saveSettings();
    } else if (result == 'discard') {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.settingsL10n;
    final dimens = AppDimens.of(context);
    final typography = AppTypography.of(context);

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
                  _buildSectionTitle(l10n.behavior, typography),
                  SizedBox(height: dimens.spacingL),
                  _buildSwitchTile(
                    title: l10n.autoStartBreakTitle,
                    subtitle: l10n.autoStartBreakSubtitle,
                    value: _autoStartBreak,
                    onChanged: (value) =>
                        setState(() => _autoStartBreak = value),
                    dimens: dimens,
                    typography: typography,
                  ),
                  SizedBox(height: dimens.spacingM),
                  _buildModeTransitionDelaySlider(l10n, dimens, typography),
                  SizedBox(height: dimens.spacingM),
                  _buildSwitchTile(
                    title: l10n.syncMusicWithTimerTitle,
                    subtitle: l10n.syncMusicWithTimerSubtitle,
                    value: _syncMusicWithTimer,
                    onChanged: (value) =>
                        setState(() => _syncMusicWithTimer = value),
                    dimens: dimens,
                    typography: typography,
                  ),
                  SizedBox(height: dimens.spacingXXL),
                  _buildSectionTitle(l10n.language, typography),
                  SizedBox(height: dimens.spacingL),
                  _buildLanguageDropdown(l10n, dimens, typography),
                  SizedBox(height: dimens.spacingXXL),
                  _buildSectionTitle(l10n.notifications, typography),
                  SizedBox(height: dimens.spacingL),
                  _buildSwitchTile(
                    title: l10n.soundNotificationsTitle,
                    subtitle: l10n.soundNotificationsSubtitle,
                    value: _soundEnabled,
                    onChanged: (value) => setState(() => _soundEnabled = value),
                    dimens: dimens,
                    typography: typography,
                  ),
                  if (_soundEnabled) ...[
                    SizedBox(height: dimens.spacingM),
                    _buildSoundSelection(l10n, dimens, typography),
                    SizedBox(height: dimens.spacingM),
                    _buildNotificationVolumeSlider(l10n, dimens, typography),
                  ],
                  SizedBox(height: dimens.spacingXXL),
                  _buildSectionTitle(l10n.audio, typography),
                  SizedBox(height: dimens.spacingL),
                  _buildVolumeSlider(l10n, dimens, typography),
                  SizedBox(height: dimens.spacingXXL),
                  _buildSectionTitle(l10n.data, typography),
                  SizedBox(height: dimens.spacingL),
                  _buildAutoClearDropdown(l10n, dimens, typography),
                  SizedBox(height: dimens.spacingXXL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppTypography typography) {
    return Text(title, style: typography.titleLarge);
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required AppDimens dimens,
    required AppTypography typography,
  }) {
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

  Widget _buildLanguageDropdown(
    SettingsL10n l10n,
    AppDimens dimens,
    AppTypography typography,
  ) {
    return Container(
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
              value: _languageCode,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.textSecondary,
                size: dimens.iconM,
              ),
              items: _languageOptions.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    l10n.languageLabel(value),
                    style: typography.bodyLarge,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _languageCode = value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTransitionDelaySlider(
    SettingsL10n l10n,
    AppDimens dimens,
    AppTypography typography,
  ) {
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
                  value: _modeTransitionDelaySeconds.toDouble(),
                  min: 0,
                  max: 15,
                  divisions: 15,
                  label: l10n.modeTransitionDelayValue(
                    _modeTransitionDelaySeconds,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _modeTransitionDelaySeconds = value.round();
                    });
                  },
                ),
              ),
              Text(
                l10n.modeTransitionDelayValue(_modeTransitionDelaySeconds),
                style: typography.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider(
    SettingsL10n l10n,
    AppDimens dimens,
    AppTypography typography,
  ) {
    return Container(
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
                _defaultVolume == 0
                    ? Icons.volume_off
                    : _defaultVolume < 0.5
                    ? Icons.volume_down
                    : Icons.volume_up,
                color: AppColors.textPrimary,
                size: dimens.iconM,
              ),
              Expanded(
                child: Slider(
                  value: _defaultVolume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) => setState(() => _defaultVolume = value),
                ),
              ),
              Text(
                '${(_defaultVolume * 100).round()}%',
                style: typography.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSelection(
    SettingsL10n l10n,
    AppDimens dimens,
    AppTypography typography,
  ) {
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
                    value: _notificationSound,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AppColors.textSecondary,
                      size: dimens.iconM,
                    ),
                    items: _soundOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option['path'],
                        child: Text(
                          l10n.soundLabel(option['id']!),
                          style: typography.bodyLarge,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _notificationSound = value);
                        _playSoundPreview();
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
                onPressed: _playSoundPreview,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationVolumeSlider(
    SettingsL10n l10n,
    AppDimens dimens,
    AppTypography typography,
  ) {
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
                _notificationVolume == 0
                    ? Icons.volume_off
                    : _notificationVolume < 0.5
                    ? Icons.volume_down
                    : Icons.volume_up,
                color: AppColors.textPrimary,
                size: dimens.iconM,
              ),
              Expanded(
                child: Slider(
                  value: _notificationVolume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) =>
                      setState(() => _notificationVolume = value),
                  onChangeEnd: (_) => _playSoundPreview(),
                ),
              ),
              Text(
                '${(_notificationVolume * 100).round()}%',
                style: typography.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutoClearDropdown(
    SettingsL10n l10n,
    AppDimens dimens,
    AppTypography typography,
  ) {
    return Container(
      padding: dimens.paddingAllL,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: dimens.borderRadiusM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.autoClearStatistics, style: typography.titleSmall),
          SizedBox(height: dimens.spacingXS),
          Text(l10n.autoClearStatisticsSubtitle, style: typography.bodyMedium),
          SizedBox(height: dimens.spacingM),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _autoClearSchedule,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.textSecondary,
                size: dimens.iconM,
              ),
              items: _autoClearOptions.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    l10n.autoClearLabel(value),
                    style: typography.bodyLarge,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _autoClearSchedule = value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
