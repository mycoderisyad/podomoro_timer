import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/music_track.dart';

enum MusicLibraryPermissionState {
  unknown,
  granted,
  denied,
  permanentlyDenied,
  unsupported,
}

class AudioLibraryResult {
  final List<MusicTrack> tracks;
  final MusicLibraryPermissionState permissionState;
  final String? errorMessage;

  const AudioLibraryResult({
    required this.tracks,
    required this.permissionState,
    this.errorMessage,
  });
}

abstract class AudioLibraryRepository {
  Future<AudioLibraryResult> fetchTracks({bool requestPermission = false});

  Future<bool> openSettings();
}

class MethodChannelAudioLibraryRepository implements AudioLibraryRepository {
  static const MethodChannel _channel = MethodChannel(
    'podomoro_timer/device_audio',
  );

  const MethodChannelAudioLibraryRepository();

  @override
  Future<AudioLibraryResult> fetchTracks({
    bool requestPermission = false,
  }) async {
    if (!Platform.isAndroid) {
      return const AudioLibraryResult(
        tracks: [],
        permissionState: MusicLibraryPermissionState.unsupported,
      );
    }

    try {
      final permissionState = await _resolvePermissionState(
        requestPermission: requestPermission,
      );

      if (permissionState != MusicLibraryPermissionState.granted) {
        return AudioLibraryResult(
          tracks: const [],
          permissionState: permissionState,
        );
      }

      final rawTracks =
          await _channel.invokeListMethod<dynamic>('getDeviceAudioTracks') ??
          const [];
      final tracks = <MusicTrack>[];

      for (final item in rawTracks) {
        if (item is! Map) {
          continue;
        }

        final json = <String, dynamic>{};
        for (final entry in item.entries) {
          json[entry.key.toString()] = entry.value;
        }

        tracks.add(
          MusicTrack(
            id: json['id']?.toString() ?? '',
            title: json['title']?.toString() ?? '',
            filePath: json['filePath']?.toString(),
            contentUri: json['contentUri']?.toString(),
            artist: json['artist']?.toString() ?? '',
            album: json['album']?.toString() ?? '',
            durationMs: json['durationMs'] is int
                ? json['durationMs'] as int
                : null,
            description: json['artist']?.toString() ?? '',
            source: MusicTrackSource.device,
          ),
        );
      }

      return AudioLibraryResult(
        tracks: tracks,
        permissionState: permissionState,
      );
    } catch (error) {
      return AudioLibraryResult(
        tracks: const [],
        permissionState: MusicLibraryPermissionState.denied,
        errorMessage: error.toString(),
      );
    }
  }

  @override
  Future<bool> openSettings() {
    return openAppSettings();
  }

  Future<MusicLibraryPermissionState> _resolvePermissionState({
    required bool requestPermission,
  }) async {
    final sdkInt = await _channel.invokeMethod<int>('getSdkInt') ?? 0;
    final permission = sdkInt >= 33 ? Permission.audio : Permission.storage;
    var status = await permission.status;

    if (!status.isGranted && requestPermission) {
      status = await permission.request();
    }

    if (status.isGranted) {
      return MusicLibraryPermissionState.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return MusicLibraryPermissionState.permanentlyDenied;
    }
    return MusicLibraryPermissionState.denied;
  }
}
