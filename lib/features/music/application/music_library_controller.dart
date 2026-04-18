import 'package:flutter/foundation.dart';

import 'package:podomoro_timer/features/music/data/audio_library_repository.dart';
import 'package:podomoro_timer/features/music/domain/music_track.dart';

class MusicLibraryController extends ChangeNotifier {
  static const int pageSize = 20;

  final AudioLibraryRepository _repository;

  MusicLibraryController({required AudioLibraryRepository repository})
    : _repository = repository;

  List<MusicTrack> _tracks = const [];
  List<MusicTrack> _selectedQueue = const [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedFileType;
  int _currentPage = 1;
  MusicLibraryPermissionState _permissionState =
      MusicLibraryPermissionState.unknown;

  List<MusicTrack> get tracks => _tracks;
  List<MusicTrack> get filteredTracks {
    final query = _searchQuery.trim().toLowerCase();
    return _tracks
        .where((track) {
          final matchesSearch =
              query.isEmpty ||
              track.title.toLowerCase().contains(query) ||
              track.artist.toLowerCase().contains(query) ||
              track.album.toLowerCase().contains(query);
          final matchesFileType =
              _selectedFileType == null ||
              track.fileExtension == _selectedFileType;
          return matchesSearch && matchesFileType;
        })
        .toList(growable: false);
  }

  List<MusicTrack> get visibleTracks => filteredTracks;
  List<MusicTrack> get pagedTracks {
    final startIndex = (_currentPage - 1) * pageSize;
    if (startIndex >= filteredTracks.length) {
      return const [];
    }

    final endIndex = (startIndex + pageSize).clamp(0, filteredTracks.length);
    return filteredTracks.sublist(startIndex, endIndex);
  }

  List<MusicTrack> get selectedQueue => _selectedQueue;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedFileType => _selectedFileType;
  int get currentPage => _currentPage;
  int get totalPages {
    if (filteredTracks.isEmpty) {
      return 1;
    }
    return (filteredTracks.length / pageSize).ceil();
  }

  MusicLibraryPermissionState get permissionState => _permissionState;
  bool get hasVisibleTracks => filteredTracks.isNotEmpty;
  bool get hasMultiplePages => totalPages > 1;
  List<String> get availableFileTypes {
    final fileTypes =
        tracks
            .map((track) => track.fileExtension)
            .where((extension) => extension.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return fileTypes;
  }

  bool get areAllVisibleTracksSelected =>
      filteredTracks.isNotEmpty &&
      filteredTracks.every(
        (track) => _selectedQueue.any((item) => item.id == track.id),
      );

  Future<void> initialize(List<MusicTrack> currentQueue) async {
    _selectedQueue = List<MusicTrack>.from(currentQueue);
    await loadTracks(requestPermission: true);
  }

  Future<void> loadTracks({bool requestPermission = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.fetchTracks(
      requestPermission: requestPermission,
    );

    _tracks = result.tracks;
    _permissionState = result.permissionState;
    _errorMessage = result.errorMessage;
    _normalizeCurrentPage();
    _isLoading = false;
    notifyListeners();
  }

  void toggleTrackInQueue(MusicTrack track) {
    final updatedQueue = List<MusicTrack>.from(_selectedQueue);
    final existingIndex = updatedQueue.indexWhere(
      (item) => item.id == track.id,
    );

    if (existingIndex >= 0) {
      updatedQueue.removeAt(existingIndex);
    } else {
      updatedQueue.add(track);
    }

    _selectedQueue = updatedQueue;
    notifyListeners();
  }

  void removeFromQueue(MusicTrack track) {
    _selectedQueue = _selectedQueue
        .where((item) => item.id != track.id)
        .toList(growable: false);
    notifyListeners();
  }

  void clearQueue() {
    _selectedQueue = const [];
    notifyListeners();
  }

  int? getQueuePosition(MusicTrack track) {
    final index = _selectedQueue.indexWhere((item) => item.id == track.id);
    return index == -1 ? null : index + 1;
  }

  Future<bool> openSettings() {
    return _repository.openSettings();
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) {
      return;
    }

    _searchQuery = value;
    _currentPage = 1;
    notifyListeners();
  }

  void setSelectedFileType(String? value) {
    if (_selectedFileType == value) {
      return;
    }

    _selectedFileType = value;
    _currentPage = 1;
    notifyListeners();
  }

  void toggleSelectAllVisibleTracks() {
    final visible = filteredTracks;
    if (visible.isEmpty) {
      return;
    }

    final updatedQueue = List<MusicTrack>.from(_selectedQueue);
    final allSelected = visible.every(
      (track) => updatedQueue.any((item) => item.id == track.id),
    );

    if (allSelected) {
      final visibleIds = visible.map((track) => track.id).toSet();
      updatedQueue.removeWhere((track) => visibleIds.contains(track.id));
    } else {
      for (final track in visible) {
        final alreadySelected = updatedQueue.any((item) => item.id == track.id);
        if (!alreadySelected) {
          updatedQueue.add(track);
        }
      }
    }

    _selectedQueue = updatedQueue;
    notifyListeners();
  }

  void goToPage(int page) {
    final normalizedPage = page.clamp(1, totalPages);
    if (_currentPage == normalizedPage) {
      return;
    }

    _currentPage = normalizedPage;
    notifyListeners();
  }

  void goToNextPage() {
    if (_currentPage >= totalPages) {
      return;
    }

    _currentPage++;
    notifyListeners();
  }

  void goToPreviousPage() {
    if (_currentPage <= 1) {
      return;
    }

    _currentPage--;
    notifyListeners();
  }

  void _normalizeCurrentPage() {
    if (_currentPage > totalPages) {
      _currentPage = totalPages;
    }
    if (_currentPage < 1) {
      _currentPage = 1;
    }
  }
}
