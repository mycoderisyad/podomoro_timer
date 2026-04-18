import 'package:flutter/widgets.dart';

import 'package:podomoro_timer/features/music/domain/music_track.dart';
import 'package:podomoro_timer/l10n/l10n.dart';

String localizedMusicTrackDescription(BuildContext context, MusicTrack track) {
  final l10n = context.musicL10n;
  final artist = track.artist.trim();
  final album = track.album.trim();
  final description = track.description.trim();

  if (artist.isNotEmpty && album.isNotEmpty) {
    return '$artist - $album';
  }

  if (artist.isNotEmpty) {
    return artist;
  }

  if (album.isNotEmpty) {
    return album;
  }

  if (description.isEmpty ||
      description == 'Custom music' ||
      description == 'custom_music') {
    return track.isDeviceTrack ? l10n.deviceMusic : l10n.customMusic;
  }

  return description;
}
