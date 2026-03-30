import 'package:audioplayers/audioplayers.dart';

class NotificationAudioService {
  NotificationAudioService._();

  static final AudioContext _notificationAudioContext = AudioContextConfig(
    route: AudioContextConfigRoute.speaker,
    focus: AudioContextConfigFocus.gain,
  ).build();

  static Future<void> playAsset({
    required AudioPlayer player,
    required String assetPath,
    required double volume,
  }) async {
    final source = AssetSource(assetPath.replaceAll('assets/', ''));

    await player.stop();
    await player.play(
      source,
      volume: volume,
      mode: PlayerMode.lowLatency,
      ctx: _notificationAudioContext,
    );
  }
}
