import 'package:audioplayers/audioplayers.dart';

abstract interface class NotificationAudioService {
  Future<void> playAsset({required String assetPath, required double volume});

  Future<void> dispose();
}

class AudioPlayerNotificationAudioService implements NotificationAudioService {
  static final AudioContext _notificationAudioContext = AudioContextConfig(
    route: AudioContextConfigRoute.speaker,
    focus: AudioContextConfigFocus.gain,
  ).build();

  final AudioPlayer _player;

  AudioPlayerNotificationAudioService({AudioPlayer? player})
    : _player = player ?? AudioPlayer();

  @override
  Future<void> playAsset({
    required String assetPath,
    required double volume,
  }) async {
    final source = AssetSource(assetPath.replaceAll('assets/', ''));

    await _player.stop();
    await _player.play(
      source,
      volume: volume,
      mode: PlayerMode.lowLatency,
      ctx: _notificationAudioContext,
    );
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
  }
}
