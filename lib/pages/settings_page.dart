import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/app_settings.dart';

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

  @override
  void initState() {
    super.initState();
    _autoStartBreak = widget.settings.autoStartBreak;
    _syncMusicWithTimer = widget.settings.syncMusicWithTimer;
    _defaultVolume = widget.settings.defaultVolume;
  }

  void _saveSettings() {
    final updatedSettings = widget.settings.copyWith(
      autoStartBreak: _autoStartBreak,
      syncMusicWithTimer: _syncMusicWithTimer,
      defaultVolume: _defaultVolume,
    );
    Navigator.pop(context, updatedSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            _buildSectionTitle('Behavior'),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Auto-Start Break',
              subtitle: 'Automatically start break after focus session',
              value: _autoStartBreak,
              onChanged: (value) => setState(() => _autoStartBreak = value),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Sync Music with Timer',
              subtitle: 'Music plays/pauses automatically with timer',
              value: _syncMusicWithTimer,
              onChanged: (value) => setState(() => _syncMusicWithTimer = value),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Audio'),
            const SizedBox(height: 16),
            _buildVolumeSlider(),
          ],
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

  Widget _buildVolumeSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Default Music Volume',
            style: TextStyle(
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
                  onChanged: (value) {
                    setState(() => _defaultVolume = value);
                  },
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
}
