import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../domain/music_track.dart';

class MusicPlaybackController extends ChangeNotifier {
  final bool Function() shouldAutoPlay;
  final AudioPlayer _audioPlayer = AudioPlayer();

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  List<MusicTrack> _musicQueue = const [];
  int _currentQueueIndex = 0;
  bool _isMusicPlaying = false;
  Duration _trackDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;

  MusicPlaybackController({required this.shouldAutoPlay});

  List<MusicTrack> get musicQueue => _musicQueue;
  int get currentQueueIndex => _currentQueueIndex;
  bool get isMusicPlaying => _isMusicPlaying;
  MusicTrack? get currentTrack =>
      _musicQueue.isEmpty ? null : _musicQueue[_currentQueueIndex];
  Duration get trackDuration => _trackDuration;
  Duration get playbackPosition => _playbackPosition;

  Future<void> initialize(double initialVolume) async {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    await _audioPlayer.setVolume(initialVolume);

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      _isMusicPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      unawaited(playNext(autoplay: shouldAutoPlay()));
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      _trackDuration = duration;
      notifyListeners();
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      _playbackPosition = position;
      notifyListeners();
    });
  }

  Future<void> syncPlayback() async {
    if (_musicQueue.isEmpty) {
      return;
    }

    if (shouldAutoPlay()) {
      await playOrResume();
      return;
    }

    if (_audioPlayer.state == PlayerState.playing) {
      await pause();
    }
  }

  Future<void> setQueue(List<MusicTrack> queue) async {
    await _audioPlayer.stop();
    _musicQueue = List<MusicTrack>.from(queue);
    _currentQueueIndex = 0;
    _isMusicPlaying = false;
    _trackDuration = Duration.zero;
    _playbackPosition = Duration.zero;
    notifyListeners();
  }

  Future<void> playOrResume() async {
    if (_musicQueue.isEmpty) {
      return;
    }

    try {
      if (_audioPlayer.state == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        await _playCurrentTrack();
      }
    } catch (_) {
      await playNext(autoplay: shouldAutoPlay());
    }
  }

  Future<void> playNext({required bool autoplay}) async {
    if (_musicQueue.isEmpty) {
      return;
    }

    _currentQueueIndex = (_currentQueueIndex + 1) % _musicQueue.length;
    notifyListeners();

    if (autoplay) {
      await _playCurrentTrack();
    }
  }

  Future<void> playPrevious({required bool autoplay}) async {
    if (_musicQueue.isEmpty) {
      return;
    }

    _currentQueueIndex =
        (_currentQueueIndex - 1 + _musicQueue.length) % _musicQueue.length;
    notifyListeners();

    if (autoplay) {
      await _playCurrentTrack();
    }
  }

  Future<void> jumpToTrack(int index, {required bool autoplay}) async {
    if (_musicQueue.isEmpty || index < 0 || index >= _musicQueue.length) {
      return;
    }

    _currentQueueIndex = index;
    notifyListeners();

    if (autoplay) {
      await _playCurrentTrack();
    }
  }

  Future<void> setVolume(double value) async {
    await _audioPlayer.setVolume(value);
  }

  Future<void> seek(Duration position) async {
    final target = position < Duration.zero ? Duration.zero : position;
    await _audioPlayer.seek(target);
    _playbackPosition = target;
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> _playCurrentTrack() async {
    if (_musicQueue.isEmpty) {
      return;
    }

    final currentTrack = _musicQueue[_currentQueueIndex];
    final source = _resolveAudioSource(currentTrack);

    if (source == null) {
      await playNext(autoplay: shouldAutoPlay());
      return;
    }

    try {
      await _audioPlayer.stop();
      _trackDuration = Duration.zero;
      _playbackPosition = Duration.zero;
      await _audioPlayer.play(source);
    } catch (_) {
      await playNext(autoplay: shouldAutoPlay());
    }
  }

  Source? _resolveAudioSource(MusicTrack track) {
    if (track.filePath != null && track.filePath!.isNotEmpty) {
      return DeviceFileSource(track.filePath!);
    }
    if (track.contentUri != null && track.contentUri!.isNotEmpty) {
      return UrlSource(track.contentUri!);
    }
    if (track.assetPath.isNotEmpty) {
      return AssetSource(track.assetPath);
    }
    return null;
  }

  @override
  void dispose() {
    unawaited(_playerStateSubscription?.cancel());
    unawaited(_playerCompleteSubscription?.cancel());
    unawaited(_durationSubscription?.cancel());
    unawaited(_positionSubscription?.cancel());
    _audioPlayer.dispose();
    super.dispose();
  }
}
