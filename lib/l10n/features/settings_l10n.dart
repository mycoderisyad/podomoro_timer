import '../app_localizations.dart';

class SettingsL10n {
  const SettingsL10n(this._base);

  final AppLocalizations _base;

  String get settings => _base.settings;
  String get saveSettingsTooltip => _base.saveSettingsTooltip;
  String get behavior => _base.behavior;
  String get autoStartBreakTitle => _base.autoStartBreakTitle;
  String get autoStartBreakSubtitle => _base.autoStartBreakSubtitle;
  String get modeTransitionDelayTitle => _base.modeTransitionDelayTitle;
  String get modeTransitionDelaySubtitle => _base.modeTransitionDelaySubtitle;
  String get syncMusicWithTimerTitle => _base.syncMusicWithTimerTitle;
  String get syncMusicWithTimerSubtitle => _base.syncMusicWithTimerSubtitle;
  String get language => _base.language;
  String get languageSubtitle => _base.languageSubtitle;
  String get notifications => _base.notifications;
  String get soundNotificationsTitle => _base.soundNotificationsTitle;
  String get soundNotificationsSubtitle => _base.soundNotificationsSubtitle;
  String get notificationSound => _base.notificationSound;
  String get notificationVolume => _base.notificationVolume;
  String get testSoundTooltip => _base.testSoundTooltip;
  String get notificationPlaybackFailed => _base.notificationPlaybackFailed;
  String get audio => _base.audio;
  String get defaultMusicVolume => _base.defaultMusicVolume;
  String get data => _base.data;
  String get autoClearStatistics => _base.autoClearStatistics;
  String get autoClearStatisticsSubtitle => _base.autoClearStatisticsSubtitle;
  String get unsavedChangesTitle => _base.unsavedChangesTitle;
  String get unsavedChangesMessage => _base.unsavedChangesMessage;
  String get cancel => _base.cancel;
  String get discardChanges => _base.discardChanges;
  String get save => _base.save;

  String languageLabel(String code) => _base.languageLabel(code);
  String soundLabel(String id) => _base.soundLabel(id);
  String autoClearLabel(String value) => _base.autoClearLabel(value);
  String modeTransitionDelayValue(int seconds) =>
      _base.modeTransitionDelayValue(seconds);
}
