import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../data/music_data.dart';
import '../models/music_track.dart';
import '../widgets/music_card.dart';

class MusicSelectionPage extends StatefulWidget {
  const MusicSelectionPage({super.key});

  @override
  State<MusicSelectionPage> createState() => _MusicSelectionPageState();
}

class _MusicSelectionPageState extends State<MusicSelectionPage> {
  MusicTrack? _currentSelection;

  void _onTrackTap(MusicTrack track) {
    setState(() {
      _currentSelection = track;
    });
    Navigator.pop(context, track);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Study Music'),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: MusicData.availableTracks.length,
          itemBuilder: (context, index) {
            final track = MusicData.availableTracks[index];
            return MusicCard(
              track: track,
              onTap: () => _onTrackTap(track),
              isSelected: _currentSelection?.id == track.id,
            );
          },
        ),
      ),
    );
  }
}
