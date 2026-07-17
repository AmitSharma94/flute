import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/song_model.dart';

class AudioScannerService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<bool> requestPermission() => _audioQuery.permissionsRequest();

  Future<bool> hasPermission() => _audioQuery.permissionsStatus();

  Future<bool> openSettings() => openAppSettings();

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
        .where((song) => song.id.isNotEmpty && song.path.trim().isNotEmpty)
        .toList(growable: false);
  }

  String _clean(String? value, String fallback) {
    final cleaned = value?.trim();
    if (cleaned == null || cleaned.isEmpty || cleaned == '<unknown>') {
      return fallback;
    }
    return cleaned;
  }
}
