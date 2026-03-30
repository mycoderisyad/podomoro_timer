import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/music_track.dart';

class MusicLibraryService {
  static const String _storageKey = 'user_music_library';

  Future<List<MusicTrack>> loadMusicLibrary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      final tracks = jsonList.map((json) => MusicTrack.fromJson(json)).toList();
      
      // Filter out tracks where the file no longer exists
      final validTracks = <MusicTrack>[];
      for (var track in tracks) {
        if (track.isLocalFile) {
          if (await File(track.filePath!).exists()) {
            validTracks.add(track);
          }
        } else {
          validTracks.add(track);
        }
      }

      if (validTracks.length != tracks.length) {
        await _saveMusicLibrary(validTracks);
      }

      return validTracks;
    } catch (e) {
      return [];
    }
  }

  Future<bool> addMusic(MusicTrack track) async {
    try {
      final tracks = await loadMusicLibrary();
      
      if (track.isLocalFile) {
        final exists = tracks.any((t) => t.filePath == track.filePath);
        if (exists) {
          return false;
        }
      }

      tracks.add(track);
      await _saveMusicLibrary(tracks);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeMusic(String trackId) async {
    try {
      final tracks = await loadMusicLibrary();
      tracks.removeWhere((track) => track.id == trackId);
      await _saveMusicLibrary(tracks);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveMusicLibrary(List<MusicTrack> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tracks.map((track) => track.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await prefs.setString(_storageKey, jsonString);
  }

  Future<bool> clearLibrary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> fileExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }
}
