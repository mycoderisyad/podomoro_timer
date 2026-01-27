import '../models/music_track.dart';
class MusicData {
  MusicData._();

  static const List<MusicTrack> availableTracks = [
    MusicTrack(
      id: '1',
      title: 'Lo-Fi Study Beats',
      assetPath: 'audio/lofi_study.mp3',
      description: 'Relaxing lo-fi beats for deep focus',
    ),
    MusicTrack(
      id: '2',
      title: 'Rain Ambience',
      assetPath: 'audio/rain_ambience.mp3',
      description: 'Gentle rain sounds for concentration',
    ),
  ];
}
