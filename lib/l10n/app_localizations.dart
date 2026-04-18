import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'locales/localized_values.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('id')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in context.');
    return localizations!;
  }

  static const Map<String, Map<String, String>> _localizedValues =
      localizedValues;

  String get _languageCode {
    final code = locale.languageCode;
    return _localizedValues.containsKey(code) ? code : 'en';
  }

  bool get isEnglish => _languageCode == 'en';
  String get localeName => _languageCode;

  String _text(String key) {
    return _localizedValues[_languageCode]![key] ??
        _localizedValues['en']![key]!;
  }

  // Shared app and shell labels.
  String appTitle() => _text('appTitle');

  // Settings screen labels.
  String get settings => _text('settings');
  String get saveSettingsTooltip => _text('saveSettingsTooltip');
  String get behavior => _text('behavior');
  String get autoStartBreakTitle => _text('autoStartBreakTitle');
  String get autoStartBreakSubtitle => _text('autoStartBreakSubtitle');
  String get modeTransitionDelayTitle => _text('modeTransitionDelayTitle');
  String get modeTransitionDelaySubtitle =>
      _text('modeTransitionDelaySubtitle');
  String get syncMusicWithTimerTitle => _text('syncMusicWithTimerTitle');
  String get syncMusicWithTimerSubtitle => _text('syncMusicWithTimerSubtitle');
  String get language => _text('language');
  String get languageSubtitle => _text('languageSubtitle');
  String get notifications => _text('notifications');
  String get soundNotificationsTitle => _text('soundNotificationsTitle');
  String get soundNotificationsSubtitle => _text('soundNotificationsSubtitle');
  String get notificationSound => _text('notificationSound');
  String get notificationVolume => _text('notificationVolume');
  String get testSoundTooltip => _text('testSoundTooltip');
  String get notificationPlaybackFailed => _text('notificationPlaybackFailed');
  String get audio => _text('audio');
  String get defaultMusicVolume => _text('defaultMusicVolume');
  String get data => _text('data');
  String get autoClearStatistics => _text('autoClearStatistics');
  String get autoClearStatisticsSubtitle =>
      _text('autoClearStatisticsSubtitle');
  String get unsavedChangesTitle => _text('unsavedChangesTitle');
  String get unsavedChangesMessage => _text('unsavedChangesMessage');
  String get cancel => _text('cancel');
  String get discardChanges => _text('discardChanges');
  String get save => _text('save');

  // Statistics screen labels.
  String get statistics => _text('statistics');
  String get deleteAllStatisticsTooltip => _text('deleteAllStatisticsTooltip');
  String get deleteAllDataTitle => _text('deleteAllDataTitle');
  String get deleteAllDataMessage => _text('deleteAllDataMessage');
  String get delete => _text('delete');
  String get today => _text('today');
  String get week => _text('week');
  String get month => _text('month');
  String get year => _text('year');
  String get sessions => _text('sessions');
  String get focus => _text('focus');
  String get breakLabel => _text('break');
  String get categoryOverview => _text('categoryOverview');
  String get uncategorizedCategory => _text('uncategorizedCategory');
  String get noCategoryData => _text('noCategoryData');
  String get totalFocusTime => _text('totalFocusTime');
  String get totalBreakTime => _text('totalBreakTime');
  String get averageFocusPerDay => _text('averageFocusPerDay');
  String get averageBreakPerDay => _text('averageBreakPerDay');
  String get focusMinutesChartTitle => _text('focusMinutesChartTitle');
  String get noDataYet => _text('noDataYet');

  // Timer and duration labels.
  String get focusSessionCompleteMessage =>
      _text('focusSessionCompleteMessage');
  String get breakEndedMessage => _text('breakEndedMessage');
  String get focusDuration => _text('focusDuration');
  String get breakDuration => _text('breakDuration');
  String get invalidDurationMessage => _text('invalidDurationMessage');
  String get preset => _text('preset');
  String get custom => _text('custom');
  String get minutes => _text('minutes');
  String get enterMinutes => _text('enterMinutes');
  String get sessionNameOptional => _text('sessionNameOptional');
  String get sessionNameHint => _text('sessionNameHint');
  String get sessionNameHelper => _text('sessionNameHelper');
  String get apply => _text('apply');
  String get durationHint => _text('durationHint');
  String get start => _text('start');
  String get pause => _text('pause');
  String get reset => _text('reset');
  String get statisticsTooltip => _text('statisticsTooltip');
  String get settingsTooltip => _text('settingsTooltip');

  // Music library and playback labels.
  String get noMusicSelected => _text('noMusicSelected');
  String get tapToSelectMusic => _text('tapToSelectMusic');
  String get musicQueue => _text('musicQueue');
  String get playing => _text('playing');
  String get playingOrder => _text('playingOrder');
  String get clearAll => _text('clearAll');
  String get selectAll => _text('selectAll');
  String get unselectAll => _text('unselectAll');
  String get allAudioTypes => _text('allAudioTypes');
  String get previousPage => _text('previousPage');
  String get nextPage => _text('nextPage');
  String get removeFromQueueTooltip => _text('removeFromQueueTooltip');
  String get musicLibrary => _text('musicLibrary');
  String get customMusic => _text('customMusic');
  String get deviceMusic => _text('deviceMusic');
  String get refreshLibrary => _text('refreshLibrary');
  String get allowAudioAccess => _text('allowAudioAccess');
  String get openSettings => _text('openSettings');
  String get audioPermissionTitle => _text('audioPermissionTitle');
  String get audioPermissionSubtitle => _text('audioPermissionSubtitle');
  String get audioPermissionPermanentlyDeniedTitle =>
      _text('audioPermissionPermanentlyDeniedTitle');
  String get audioPermissionPermanentlyDeniedSubtitle =>
      _text('audioPermissionPermanentlyDeniedSubtitle');
  String get noDeviceMusicTitle => _text('noDeviceMusicTitle');
  String get noDeviceMusicSubtitle => _text('noDeviceMusicSubtitle');
  String get androidOnlyMusicLibraryTitle =>
      _text('androidOnlyMusicLibraryTitle');
  String get androidOnlyMusicLibrarySubtitle =>
      _text('androidOnlyMusicLibrarySubtitle');
  String get searchMusicHint => _text('searchMusicHint');
  String get clearSearchTooltip => _text('clearSearchTooltip');
  String get clearSearch => _text('clearSearch');
  String get noSearchResultsTitle => _text('noSearchResultsTitle');
  String get noSearchResultsSubtitle => _text('noSearchResultsSubtitle');

  // Shared formatting helpers.
  String languageLabel(String code) {
    return code == 'id'
        ? _text('languageIndonesian')
        : _text('languageEnglish');
  }

  String soundLabel(String id) {
    switch (id) {
      case 'chime':
        return _text('chime');
      case 'ding':
        return _text('ding');
      case 'bell':
      default:
        return _text('bell');
    }
  }

  String autoClearLabel(String value) {
    switch (value) {
      case '7_days':
        return _text('autoClear7Days');
      case '30_days':
        return _text('autoClear30Days');
      case '3_months':
        return _text('autoClear3Months');
      case '1_year':
        return _text('autoClear1Year');
      case 'never':
      default:
        return _text('autoClearNever');
    }
  }

  String switchToMode(String mode) {
    return isEnglish ? 'Switch to $mode' : 'Ganti ke $mode';
  }

  String sessionCount(int count) {
    return isEnglish ? 'Session #$count' : 'Sesi #$count';
  }

  String trackCount(int count) {
    if (isEnglish) {
      return '$count ${count == 1 ? 'track' : 'tracks'}';
    }
    return '$count lagu';
  }

  String selectedTrackCount(int count) {
    if (isEnglish) {
      return '$count ${count == 1 ? 'track selected' : 'tracks selected'}';
    }
    return '$count lagu dipilih';
  }

  String filteredTrackCount(int count, int currentPage, int totalPages) {
    if (isEnglish) {
      return '$count results | Page $currentPage/$totalPages';
    }
    return '$count hasil | Halaman $currentPage/$totalPages';
  }

  String pageIndicator(int currentPage, int totalPages) {
    return isEnglish
        ? 'Page $currentPage of $totalPages'
        : 'Halaman $currentPage dari $totalPages';
  }

  String audioTypeLabel(String extension) {
    if (extension == 'unknown') {
      return isEnglish ? 'Unknown' : 'Tidak diketahui';
    }
    return extension.toUpperCase();
  }

  String useTracks(int count) {
    if (isEnglish) {
      return 'Use $count ${count == 1 ? 'Track' : 'Tracks'}';
    }
    return 'Gunakan $count Lagu';
  }

  String minutesValue(Object value) {
    return '$value ${isEnglish ? 'min' : 'menit'}';
  }

  String modeTransitionDelayValue(int seconds) {
    if (seconds == 0) {
      return isEnglish ? 'No delay' : 'Tanpa jeda';
    }
    return isEnglish ? '$seconds sec' : '$seconds dtk';
  }

  String transitionStatusLabel(String mode, int seconds) {
    return isEnglish
        ? 'Switching to $mode in $seconds s'
        : 'Pindah ke $mode dalam $seconds dtk';
  }

  String headingToModeLabel(String mode) {
    return _text('headingToMode').replaceFirst('{mode}', mode);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
