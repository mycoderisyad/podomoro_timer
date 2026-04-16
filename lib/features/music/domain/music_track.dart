enum MusicTrackSource { asset, device, custom }

const String unknownAudioFileType = 'unknown';

class MusicTrack {
  final String id;
  final String title;
  final String assetPath;
  final String description;
  final String? filePath;
  final String? contentUri;
  final String artist;
  final String album;
  final int? durationMs;
  final MusicTrackSource source;
  final bool isUserAdded;

  const MusicTrack({
    required this.id,
    required this.title,
    this.assetPath = '',
    this.description = '',
    this.filePath,
    this.contentUri,
    this.artist = '',
    this.album = '',
    this.durationMs,
    this.source = MusicTrackSource.asset,
    this.isUserAdded = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'assetPath': assetPath,
      'description': description,
      'filePath': filePath,
      'contentUri': contentUri,
      'artist': artist,
      'album': album,
      'durationMs': durationMs,
      'source': source.name,
      'isUserAdded': isUserAdded,
    };
  }

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    return MusicTrack(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      assetPath: (json['assetPath'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      filePath: json['filePath']?.toString(),
      contentUri: json['contentUri']?.toString(),
      artist: (json['artist'] ?? '').toString(),
      album: (json['album'] ?? '').toString(),
      durationMs: json['durationMs'] is int ? json['durationMs'] as int : null,
      source: _sourceFromString(json['source']?.toString()),
      isUserAdded: json['isUserAdded'] == true,
    );
  }

  String get sourcePath {
    if (filePath != null && filePath!.isNotEmpty) {
      return filePath!;
    }
    if (contentUri != null && contentUri!.isNotEmpty) {
      return contentUri!;
    }
    return assetPath;
  }

  bool get isLocalFile => filePath != null && filePath!.isNotEmpty;

  bool get isDeviceTrack =>
      source == MusicTrackSource.device ||
      (contentUri != null && contentUri!.isNotEmpty);

  String get fileExtension {
    final pathCandidates = [
      filePath,
      assetPath.isNotEmpty ? assetPath : null,
      contentUri,
    ];

    for (final candidate in pathCandidates) {
      if (candidate == null || candidate.isEmpty) {
        continue;
      }

      final normalized = candidate.split('?').first;
      final lastSegment = normalized.split('/').last;
      final dotIndex = lastSegment.lastIndexOf('.');
      if (dotIndex == -1 || dotIndex == lastSegment.length - 1) {
        continue;
      }

      return lastSegment.substring(dotIndex + 1).toLowerCase();
    }

    return unknownAudioFileType;
  }

  static MusicTrackSource _sourceFromString(String? value) {
    switch (value) {
      case 'device':
        return MusicTrackSource.device;
      case 'custom':
        return MusicTrackSource.custom;
      case 'asset':
      default:
        return MusicTrackSource.asset;
    }
  }
}
