import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('id'),
  ];

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

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Pomodoro Timer',
      'settings': 'Settings',
      'saveSettingsTooltip': 'Save settings',
      'behavior': 'Behavior',
      'autoStartBreakTitle': 'Auto-Start Break',
      'autoStartBreakSubtitle':
          'Automatically start break after a focus session',
      'syncMusicWithTimerTitle': 'Sync Music with Timer',
      'syncMusicWithTimerSubtitle':
          'Automatically play and pause music with the timer',
      'language': 'Language',
      'languageSubtitle': 'Choose the app language',
      'languageEnglish': 'English',
      'languageIndonesian': 'Indonesian',
      'notifications': 'Notifications',
      'soundNotificationsTitle': 'Sound Notifications',
      'soundNotificationsSubtitle': 'Play a sound when a session ends',
      'notificationSound': 'Notification Sound',
      'notificationVolume': 'Notification Volume',
      'testSoundTooltip': 'Test sound',
      'notificationPlaybackFailed': 'Unable to play notification sound',
      'audio': 'Audio',
      'defaultMusicVolume': 'Default Music Volume',
      'data': 'Data',
      'autoClearStatistics': 'Auto-Clear Statistics',
      'autoClearStatisticsSubtitle':
          'Automatically clear statistics based on a schedule',
      'autoClearNever': 'Never',
      'autoClear7Days': 'Every 7 days',
      'autoClear30Days': 'Every 30 days',
      'autoClear3Months': 'Every 3 months',
      'autoClear1Year': 'Every year',
      'unsavedChangesTitle': 'Unsaved Changes',
      'unsavedChangesMessage':
          'You have unsaved changes. What would you like to do?',
      'cancel': 'Cancel',
      'discardChanges': 'Discard Changes',
      'save': 'Save',
      'bell': 'Bell',
      'chime': 'Chime',
      'ding': 'Ding',
      'statistics': 'Statistics',
      'deleteAllStatisticsTooltip': 'Delete all data',
      'deleteAllDataTitle': 'Delete All Data',
      'deleteAllDataMessage':
          'Are you sure you want to delete all statistics? This action cannot be undone.',
      'delete': 'Delete',
      'today': 'Today',
      'week': 'Week',
      'month': 'Month',
      'year': 'Year',
      'sessions': 'Sessions',
      'focus': 'Focus',
      'break': 'Break',
      'average': 'Average',
      'focusMinutesChartTitle': 'Focus (minutes)',
      'noDataYet': 'No data yet',
      'focusSessionCompleteMessage':
          'Focus session complete! Time for a break.',
      'breakEndedTitle': 'Break Finished',
      'breakEndedMessage':
          'Your break is over. Time to focus again!',
      'ok': 'OK',
      'focusDuration': 'Focus Duration',
      'breakDuration': 'Break Duration',
      'invalidDurationMessage':
          'Please enter a valid duration (1-180 minutes)',
      'preset': 'Preset',
      'custom': 'Custom',
      'minutes': 'Minutes',
      'enterMinutes': 'Enter minutes',
      'apply': 'Apply',
      'durationHint': 'Enter any duration from 1 to 180 minutes',
      'start': 'Start',
      'pause': 'Pause',
      'reset': 'Reset',
      'statisticsTooltip': 'Statistics',
      'settingsTooltip': 'Settings',
      'noMusicSelected': 'No Music Selected',
      'tapToSelectMusic': 'Tap to select music',
      'musicQueue': 'Music Queue',
      'playing': 'Playing',
      'playingOrder': 'Playing Order',
      'clearAll': 'Clear All',
      'removeFromQueueTooltip': 'Remove from queue',
      'emptyLibraryTitle': 'Your library is empty',
      'importMusicFiles': 'Import Music Files',
      'musicLibrary': 'Music Library',
      'addCustomMusicTooltip': 'Add custom music',
      'storagePermissionRequired':
          'Storage permission is required to add music',
      'musicAlreadyInLibrary': 'Music is already in your library',
      'deleteMusicTitle': 'Delete Music',
      'customMusic': 'Custom music',
    },
    'id': {
      'appTitle': 'Pomodoro Timer',
      'settings': 'Pengaturan',
      'saveSettingsTooltip': 'Simpan pengaturan',
      'behavior': 'Perilaku',
      'autoStartBreakTitle': 'Mulai Istirahat Otomatis',
      'autoStartBreakSubtitle':
          'Mulai waktu istirahat otomatis setelah sesi fokus selesai',
      'syncMusicWithTimerTitle': 'Sinkronkan Musik dengan Timer',
      'syncMusicWithTimerSubtitle':
          'Putar dan jeda musik otomatis mengikuti timer',
      'language': 'Bahasa',
      'languageSubtitle': 'Pilih bahasa aplikasi',
      'languageEnglish': 'Inggris',
      'languageIndonesian': 'Indonesia',
      'notifications': 'Notifikasi',
      'soundNotificationsTitle': 'Notifikasi Suara',
      'soundNotificationsSubtitle':
          'Putar suara saat sesi selesai',
      'notificationSound': 'Suara Notifikasi',
      'notificationVolume': 'Volume Notifikasi',
      'testSoundTooltip': 'Coba suara',
      'notificationPlaybackFailed': 'Gagal memutar suara notifikasi',
      'audio': 'Audio',
      'defaultMusicVolume': 'Volume Musik Default',
      'data': 'Data',
      'autoClearStatistics': 'Hapus Statistik Otomatis',
      'autoClearStatisticsSubtitle':
          'Hapus statistik otomatis berdasarkan jadwal',
      'autoClearNever': 'Tidak pernah',
      'autoClear7Days': 'Setiap 7 hari',
      'autoClear30Days': 'Setiap 30 hari',
      'autoClear3Months': 'Setiap 3 bulan',
      'autoClear1Year': 'Setiap tahun',
      'unsavedChangesTitle': 'Perubahan Belum Disimpan',
      'unsavedChangesMessage':
          'Ada perubahan yang belum disimpan. Apa yang ingin Anda lakukan?',
      'cancel': 'Batal',
      'discardChanges': 'Buang Perubahan',
      'save': 'Simpan',
      'bell': 'Lonceng',
      'chime': 'Genta',
      'ding': 'Ding',
      'statistics': 'Statistik',
      'deleteAllStatisticsTooltip': 'Hapus semua data',
      'deleteAllDataTitle': 'Hapus Semua Data',
      'deleteAllDataMessage':
          'Yakin ingin menghapus semua statistik? Tindakan ini tidak dapat dibatalkan.',
      'delete': 'Hapus',
      'today': 'Hari Ini',
      'week': 'Minggu',
      'month': 'Bulan',
      'year': 'Tahun',
      'sessions': 'Sesi',
      'focus': 'Fokus',
      'break': 'Istirahat',
      'average': 'Rata-rata',
      'focusMinutesChartTitle': 'Fokus (menit)',
      'noDataYet': 'Belum ada data',
      'focusSessionCompleteMessage':
          'Sesi fokus selesai! Saatnya istirahat.',
      'breakEndedTitle': 'Istirahat Selesai',
      'breakEndedMessage':
          'Waktu istirahat selesai. Saatnya fokus lagi!',
      'ok': 'OK',
      'focusDuration': 'Durasi Fokus',
      'breakDuration': 'Durasi Istirahat',
      'invalidDurationMessage':
          'Masukkan durasi yang valid (1-180 menit)',
      'preset': 'Preset',
      'custom': 'Kustom',
      'minutes': 'Menit',
      'enterMinutes': 'Masukkan menit',
      'apply': 'Terapkan',
      'durationHint': 'Masukkan durasi antara 1 sampai 180 menit',
      'start': 'Mulai',
      'pause': 'Jeda',
      'reset': 'Reset',
      'statisticsTooltip': 'Statistik',
      'settingsTooltip': 'Pengaturan',
      'noMusicSelected': 'Belum Ada Musik',
      'tapToSelectMusic': 'Ketuk untuk memilih musik',
      'musicQueue': 'Antrean Musik',
      'playing': 'Diputar',
      'playingOrder': 'Urutan Putar',
      'clearAll': 'Hapus Semua',
      'removeFromQueueTooltip': 'Hapus dari antrean',
      'emptyLibraryTitle': 'Pustaka musik Anda kosong',
      'importMusicFiles': 'Impor File Musik',
      'musicLibrary': 'Pustaka Musik',
      'addCustomMusicTooltip': 'Tambah musik kustom',
      'storagePermissionRequired':
          'Izin penyimpanan diperlukan untuk menambahkan musik',
      'musicAlreadyInLibrary': 'Musik sudah ada di pustaka Anda',
      'deleteMusicTitle': 'Hapus Musik',
      'customMusic': 'Musik kustom',
    },
  };

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

  String appTitle() => _text('appTitle');
  String get settings => _text('settings');
  String get saveSettingsTooltip => _text('saveSettingsTooltip');
  String get behavior => _text('behavior');
  String get autoStartBreakTitle => _text('autoStartBreakTitle');
  String get autoStartBreakSubtitle => _text('autoStartBreakSubtitle');
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
  String get autoClearStatisticsSubtitle => _text('autoClearStatisticsSubtitle');
  String get unsavedChangesTitle => _text('unsavedChangesTitle');
  String get unsavedChangesMessage => _text('unsavedChangesMessage');
  String get cancel => _text('cancel');
  String get discardChanges => _text('discardChanges');
  String get save => _text('save');
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
  String get average => _text('average');
  String get focusMinutesChartTitle => _text('focusMinutesChartTitle');
  String get noDataYet => _text('noDataYet');
  String get focusSessionCompleteMessage => _text('focusSessionCompleteMessage');
  String get breakEndedTitle => _text('breakEndedTitle');
  String get breakEndedMessage => _text('breakEndedMessage');
  String get ok => _text('ok');
  String get focusDuration => _text('focusDuration');
  String get breakDuration => _text('breakDuration');
  String get invalidDurationMessage => _text('invalidDurationMessage');
  String get preset => _text('preset');
  String get custom => _text('custom');
  String get minutes => _text('minutes');
  String get enterMinutes => _text('enterMinutes');
  String get apply => _text('apply');
  String get durationHint => _text('durationHint');
  String get start => _text('start');
  String get pause => _text('pause');
  String get reset => _text('reset');
  String get statisticsTooltip => _text('statisticsTooltip');
  String get settingsTooltip => _text('settingsTooltip');
  String get noMusicSelected => _text('noMusicSelected');
  String get tapToSelectMusic => _text('tapToSelectMusic');
  String get musicQueue => _text('musicQueue');
  String get playing => _text('playing');
  String get playingOrder => _text('playingOrder');
  String get clearAll => _text('clearAll');
  String get removeFromQueueTooltip => _text('removeFromQueueTooltip');
  String get emptyLibraryTitle => _text('emptyLibraryTitle');
  String get importMusicFiles => _text('importMusicFiles');
  String get musicLibrary => _text('musicLibrary');
  String get addCustomMusicTooltip => _text('addCustomMusicTooltip');
  String get storagePermissionRequired => _text('storagePermissionRequired');
  String get musicAlreadyInLibrary => _text('musicAlreadyInLibrary');
  String get deleteMusicTitle => _text('deleteMusicTitle');
  String get customMusic => _text('customMusic');

  String languageLabel(String code) {
    return code == 'id' ? _text('languageIndonesian') : _text('languageEnglish');
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

  String queueSummary(int current, int total) {
    return isEnglish
        ? 'Queue: $current/$total - Tap to view'
        : 'Antrean: $current/$total - Ketuk untuk melihat';
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

  String useTracks(int count) {
    if (isEnglish) {
      return 'Use $count ${count == 1 ? 'Track' : 'Tracks'}';
    }
    return 'Gunakan $count Lagu';
  }

  String addedMusicFiles(int count) {
    if (isEnglish) {
      return 'Added $count ${count == 1 ? 'music file' : 'music files'}';
    }
    return 'Berhasil menambahkan $count file musik';
  }

  String errorAddingMusic(String error) {
    return isEnglish
        ? 'Error adding music: $error'
        : 'Gagal menambahkan musik: $error';
  }

  String deleteMusicMessage(String title) {
    return isEnglish
        ? 'Are you sure you want to remove "$title" from your library?'
        : 'Yakin ingin menghapus "$title" dari pustaka Anda?';
  }

  String removedTrack(String title) {
    return isEnglish ? 'Removed: $title' : 'Dihapus: $title';
  }

  String minutesValue(Object value) {
    return '$value ${isEnglish ? 'min' : 'menit'}';
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
