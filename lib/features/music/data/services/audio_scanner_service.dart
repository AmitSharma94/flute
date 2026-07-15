import 'package:on_audio_query/on_audio_query.dart';

import '../models/song_model.dart';

class AudioScannerService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<bool> requestPermission() async {
    return await _audioQuery.permissionsRequest();
  }

  Future<List<FluteSong>> getSongs() async {
    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    return songs.map((song) {
      return FluteSong(
        id: song.id,
        title: song.title,
        artist: song.artist ?? 'Unknown Artist',
        album: song.album ?? 'Unknown Album',
        duration: song.duration ?? 0,
        path: song.data,
      );
    }).toList();
  }
}