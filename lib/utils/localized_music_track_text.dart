import 'package:flutter/widgets.dart';

import '../l10n/l10n.dart';
import '../models/music_track.dart';

String localizedMusicTrackDescription(BuildContext context, MusicTrack track) {
  final description = track.description.trim();

  if (description.isEmpty ||
      description == 'Custom music' ||
      description == 'custom_music') {
    return context.l10n.customMusic;
  }

  return description;
}
