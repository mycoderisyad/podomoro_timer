import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../services/notification_audio_service.dart';

class SettingsPage extends StatefulWidget {
  final AppSettings settings;

  const SettingsPage({super.key, required this.settings});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _autoStartBreak;
  late bool _syncMusicWithTimer;
  late double _defaultVolume;
  late bool _soundEnabled;
  late String _notificationSound;
  late double _notificationVolume;
  late String _autoClearSchedule;
  late String _languageCode;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, String>> _soundOptions = [
    {
      'id': 'bell',
      'path': 'assets/audio/notifications/bell.ogg',
    },
    {
      'id': 'chime',
      'path': 'assets/audio/notifications/chime.ogg',
    },
    {
      'id': 'ding',
      'path': 'assets/audio/notifications/ding.ogg',
    },
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
          content: Text(context.l10n.notificationPlaybackFailed),
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

    final l10n = context.l10n;
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.unsavedChangesTitle),
          content: Text(l10n.unsavedChangesMessage),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
    final l10n = context.l10n;

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
            onPressed: () => _handleBackNavigation(false),
          ),
          title: Text(
            l10n.settings,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _saveSettings,
              icon: const Icon(Icons.check_circle_rounded),
              color: AppColors.primary,
              iconSize: 28,
              tooltip: l10n.saveSettingsTooltip,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              _buildSectionTitle(l10n.behavior),
              const SizedBox(height: 16),
              _buildSwitchTile(
                title: l10n.autoStartBreakTitle,
                subtitle: l10n.autoStartBreakSubtitle,
                value: _autoStartBreak,
                onChanged: (value) =>
                    setState(() => _autoStartBreak = value),
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                title: l10n.syncMusicWithTimerTitle,
                subtitle: l10n.syncMusicWithTimerSubtitle,
                value: _syncMusicWithTimer,
                onChanged: (value) =>
                    setState(() => _syncMusicWithTimer = value),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(l10n.language),
              const SizedBox(height: 16),
              _buildLanguageDropdown(l10n),
              const SizedBox(height: 24),
              _buildSectionTitle(l10n.notifications),
              const SizedBox(height: 16),
              _buildSwitchTile(
                title: l10n.soundNotificationsTitle,
                subtitle: l10n.soundNotificationsSubtitle,
                value: _soundEnabled,
                onChanged: (value) =>
                    setState(() => _soundEnabled = value),
              ),
              if (_soundEnabled) ...[
                const SizedBox(height: 12),
                _buildSoundSelection(l10n),
                const SizedBox(height: 12),
                _buildNotificationVolumeSlider(l10n),
              ],
              const SizedBox(height: 24),
              _buildSectionTitle(l10n.audio),
              const SizedBox(height: 16),
              _buildVolumeSlider(l10n),
              const SizedBox(height: 24),
              _buildSectionTitle(l10n.data),
              const SizedBox(height: 16),
              _buildAutoClearDropdown(l10n),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
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

  Widget _buildLanguageDropdown(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.language,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.languageSubtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _languageCode,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.textSecondary,
              ),
              items: _languageOptions.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    l10n.languageLabel(value),
                    style: const TextStyle(color: AppColors.textPrimary),
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

  Widget _buildVolumeSlider(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.defaultMusicVolume,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _defaultVolume == 0
                    ? Icons.volume_off
                    : _defaultVolume < 0.5
                        ? Icons.volume_down
                        : Icons.volume_up,
                color: AppColors.textPrimary,
                size: 20,
              ),
              Expanded(
                child: Slider(
                  value: _defaultVolume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) =>
                      setState(() => _defaultVolume = value),
                ),
              ),
              Text(
                '${(_defaultVolume * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSelection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notificationSound,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _notificationSound,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    icon: const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                    items: _soundOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option['path'],
                        child: Text(
                          l10n.soundLabel(option['id']!),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                          ),
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
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.play_circle_fill_rounded),
                color: AppColors.primary,
                iconSize: 32,
                tooltip: l10n.testSoundTooltip,
                onPressed: _playSoundPreview,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationVolumeSlider(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notificationVolume,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _notificationVolume == 0
                    ? Icons.volume_off
                    : _notificationVolume < 0.5
                        ? Icons.volume_down
                        : Icons.volume_up,
                color: AppColors.textPrimary,
                size: 20,
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutoClearDropdown(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.autoClearStatistics,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.autoClearStatisticsSubtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _autoClearSchedule,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.textSecondary,
              ),
              items: _autoClearOptions.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    l10n.autoClearLabel(value),
                    style: const TextStyle(color: AppColors.textPrimary),
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
