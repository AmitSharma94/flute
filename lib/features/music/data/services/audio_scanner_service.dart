import 'dart:io';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/song_model.dart';

class AudioScannerService {
  AudioScannerService({
    OnAudioQuery? audioQuery,
  }) : _audioQuery = audioQuery ?? OnAudioQuery();

  final OnAudioQuery _audioQuery;

  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final granted = await _audioQuery.permissionsRequest();

    if (granted) {
      return true;
    }

    final audioStatus = await Permission.audio.request();

    if (audioStatus.isGranted) {
      return true;
    }

    final storageStatus = await Permission.storage.request();

    return storageStatus.isGranted;
  }

  Future<bool> hasPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final queryPermission = await _audioQuery.permissionsStatus();

    if (queryPermission) {
      return true;
    }

    final audioGranted = await Permission.audio.isGranted;
    final storageGranted = await Permission.storage.isGranted;

    return audioGranted || storageGranted;
  }

  Future<List<FluteSong>> getSongs() async {
    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    return songs
        .map(
          (song) => FluteSong(
            id: song.id.toString(),
            title: _clean(song.title, 'Unknown Title'),
            artist: _clean(song.artist, 'Unknown Artist'),
            album: _clean(song.album, 'Unknown Album'),
            duration: song.duration ?? 0,
            path: song.data,
          ),
        )
        .where(
          (song) => song.id.isNotEmpty && song.path.trim().isNotEmpty,
        )
        .toList(growable: false);
  }

  Future<bool> openSettings() async {
    return openAppSettings();
  }

  String _clean(String? value, String fallback) {
    final cleaned = value?.trim();

    if (cleaned == null ||
        cleaned.isEmpty ||
        cleaned.toLowerCase() == '<unknown>') {
      return fallback;
    }

    return cleaned;
  }
}