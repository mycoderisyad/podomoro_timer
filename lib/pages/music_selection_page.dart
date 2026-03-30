import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/theme/app_colors.dart';
import '../l10n/l10n.dart';
import '../models/music_track.dart';
import '../services/music_library_service.dart';
import '../widgets/empty_music_library.dart';
import '../widgets/music_queue_card.dart';
import '../widgets/music_queue_preview.dart';

class MusicSelectionPage extends StatefulWidget {
  final List<MusicTrack>? currentQueue;

  const MusicSelectionPage({
    super.key,
    this.currentQueue,
  });

  @override
  State<MusicSelectionPage> createState() => _MusicSelectionPageState();
}

class _MusicSelectionPageState extends State<MusicSelectionPage> {
  final MusicLibraryService _musicLibraryService = MusicLibraryService();
  List<MusicTrack> _musicTracks = [];
  List<MusicTrack> _selectedQueue = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.currentQueue != null) {
      _selectedQueue = List.from(widget.currentQueue!);
    }
    _loadMusic();
  }

  Future<void> _loadMusic() async {
    setState(() => _isLoading = true);
    final tracks = await _musicLibraryService.loadMusicLibrary();
    setState(() {
      _musicTracks = tracks;
      _isLoading = false;
    });
  }

  Future<void> _pickMusicFile() async {
    final l10n = context.l10n;

    try {
      if (await Permission.audio.isDenied) {
        final status = await Permission.audio.request();
        if (!status.isGranted && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.storagePermissionRequired),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        int addedCount = 0;

        for (final file in result.files) {
          final filePath = file.path;
          if (filePath == null) continue;

          final fileName = file.name.replaceAll(RegExp(r'\.[^\.]+$'), '');
          final track = MusicTrack(
            id:
                '${DateTime.now().millisecondsSinceEpoch}${fileName.hashCode}',
            title: fileName,
            filePath: filePath,
            isUserAdded: true,
            description: 'custom_music',
          );

          final added = await _musicLibraryService.addMusic(track);
          if (added) addedCount++;
        }

        if (mounted) {
          if (addedCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.addedMusicFiles(addedCount)),
                duration: const Duration(seconds: 2),
              ),
            );
            _loadMusic();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.musicAlreadyInLibrary),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorAddingMusic(e.toString())),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _toggleTrackInQueue(MusicTrack track) {
    setState(() {
      final existingIndex = _selectedQueue.indexWhere((t) => t.id == track.id);
      if (existingIndex != -1) {
        _selectedQueue.removeAt(existingIndex);
      } else {
        _selectedQueue.add(track);
      }
    });
  }

  void _removeFromQueue(MusicTrack track) {
    setState(() {
      _selectedQueue.removeWhere((t) => t.id == track.id);
    });
  }

  int? _getQueuePosition(MusicTrack track) {
    final index = _selectedQueue.indexWhere((t) => t.id == track.id);
    return index != -1 ? index + 1 : null;
  }

  void _confirmSelection() {
    Navigator.pop(context, _selectedQueue);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasSelection = _selectedQueue.isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          Navigator.of(context).pop(_selectedQueue);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.pop(context, _selectedQueue),
          ),
          title: Text(
            l10n.musicLibrary,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _pickMusicFile,
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: AppColors.primary,
              iconSize: 28,
              tooltip: l10n.addCustomMusicTooltip,
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: hasSelection
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FloatingActionButton.extended(
                  onPressed: _confirmSelection,
                  backgroundColor: AppColors.textPrimary,
                  elevation: 4,
                  highlightElevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  icon: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.surfaceLight,
                  ),
                  label: Text(
                    l10n.useTracks(_selectedQueue.length),
                    style: const TextStyle(
                      color: AppColors.surfaceLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            : null,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  MusicQueuePreview(
                    selectedQueue: _selectedQueue,
                    onClearAll: () => setState(() => _selectedQueue.clear()),
                    onRemoveTrack: _removeFromQueue,
                  ),
                  Expanded(
                    child: _musicTracks.isEmpty
                        ? EmptyMusicLibrary(onImportPressed: _pickMusicFile)
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              16,
                              16,
                              hasSelection ? 100 : 20,
                            ),
                            itemCount: _musicTracks.length,
                            itemBuilder: (listContext, index) {
                              final track = _musicTracks[index];
                              final queuePosition = _getQueuePosition(track);

                              return Dismissible(
                                key: Key(track.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        l10n.delete,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ],
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog<bool>(
                                    context: listContext,
                                    builder: (dialogContext) => AlertDialog(
                                      title: Text(l10n.deleteMusicTitle),
                                      content: Text(
                                        l10n.deleteMusicMessage(track.title),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            false,
                                          ),
                                          child: Text(l10n.cancel),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            true,
                                          ),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(l10n.delete),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (direction) async {
                                  final trackTitle = track.title;
                                  final messenger =
                                      ScaffoldMessenger.of(listContext);
                                  _removeFromQueue(track);
                                  await _musicLibraryService.removeMusic(track.id);
                                  await _loadMusic();
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.removedTrack(trackTitle),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: MusicQueueCard(
                                  track: track,
                                  onTap: () => _toggleTrackInQueue(track),
                                  isSelected: queuePosition != null,
                                  queuePosition: queuePosition,
                                  onRemoveFromQueue: queuePosition != null
                                      ? () => _removeFromQueue(track)
                                      : null,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
