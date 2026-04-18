import '../app_localizations.dart';

class MusicL10n {
  const MusicL10n(this._base);

  final AppLocalizations _base;

  String get noMusicSelected => _base.noMusicSelected;
  String get tapToSelectMusic => _base.tapToSelectMusic;
  String get musicQueue => _base.musicQueue;
  String get playing => _base.playing;
  String get playingOrder => _base.playingOrder;
  String get clearAll => _base.clearAll;
  String get selectAll => _base.selectAll;
  String get unselectAll => _base.unselectAll;
  String get allAudioTypes => _base.allAudioTypes;
  String get previousPage => _base.previousPage;
  String get nextPage => _base.nextPage;
  String get removeFromQueueTooltip => _base.removeFromQueueTooltip;
  String get musicLibrary => _base.musicLibrary;
  String get customMusic => _base.customMusic;
  String get deviceMusic => _base.deviceMusic;
  String get refreshLibrary => _base.refreshLibrary;
  String get allowAudioAccess => _base.allowAudioAccess;
  String get openSettings => _base.openSettings;
  String get audioPermissionTitle => _base.audioPermissionTitle;
  String get audioPermissionSubtitle => _base.audioPermissionSubtitle;
  String get audioPermissionPermanentlyDeniedTitle =>
      _base.audioPermissionPermanentlyDeniedTitle;
  String get audioPermissionPermanentlyDeniedSubtitle =>
      _base.audioPermissionPermanentlyDeniedSubtitle;
  String get noDeviceMusicTitle => _base.noDeviceMusicTitle;
  String get noDeviceMusicSubtitle => _base.noDeviceMusicSubtitle;
  String get androidOnlyMusicLibraryTitle => _base.androidOnlyMusicLibraryTitle;
  String get androidOnlyMusicLibrarySubtitle =>
      _base.androidOnlyMusicLibrarySubtitle;
  String get searchMusicHint => _base.searchMusicHint;
  String get clearSearchTooltip => _base.clearSearchTooltip;
  String get clearSearch => _base.clearSearch;
  String get noSearchResultsTitle => _base.noSearchResultsTitle;
  String get noSearchResultsSubtitle => _base.noSearchResultsSubtitle;

  String trackCount(int count) => _base.trackCount(count);
  String selectedTrackCount(int count) => _base.selectedTrackCount(count);
  String filteredTrackCount(int count, int currentPage, int totalPages) =>
      _base.filteredTrackCount(count, currentPage, totalPages);
  String pageIndicator(int currentPage, int totalPages) =>
      _base.pageIndicator(currentPage, totalPages);
  String audioTypeLabel(String extension) => _base.audioTypeLabel(extension);
  String useTracks(int count) => _base.useTracks(count);
}
