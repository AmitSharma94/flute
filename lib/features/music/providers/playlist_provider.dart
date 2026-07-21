import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_service.dart';
import '../data/models/playlist_model.dart';
import '../data/models/song_model.dart';

class PlaylistNotifier extends Notifier<List<FlutePlaylist>> {
  bool _loaded = false;

  @override
  List<FlutePlaylist> build() {
    if (!_loaded) {
      _loaded = true;
      Future<void>.microtask(_loadPlaylists);
    }

    return const [];
  }

  Future<void> _loadPlaylists() async {
    try {
      final data = await StorageService.load(
        StorageService.playlistsKey,
      );

      final loaded = data
          .whereType<Map>()
          .map(
            (item) => FlutePlaylist.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((playlist) => playlist.id.isNotEmpty)
          .toList();

      state = loaded;
    } catch (_) {
      // Keep the current state if storage loading fails.
    }
  }

  Future<FlutePlaylist> createPlaylist(String name) async {
    final playlist = FlutePlaylist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      songs: const [],
      createdAt: DateTime.now(),
    );

    state = [...state, playlist];
    await _persist();

    return playlist;
  }

  Future<void> deletePlaylist(String playlistId) async {
    state = state
        .where((playlist) => playlist.id != playlistId)
        .toList();

    await _persist();
  }

  Future<void> addSong(
    String playlistId,
    FluteSong song,
  ) async {
    state = state.map((playlist) {
      if (playlist.id != playlistId) {
        return playlist;
      }

      if (playlist.songs.contains(song)) {
        return playlist;
      }

      return playlist.copyWith(
        songs: [...playlist.songs, song],
      );
    }).toList();

    await _persist();
  }

  Future<void> removeSong(
    String playlistId,
    String songId,
  ) async {
    state = state.map((playlist) {
      if (playlist.id != playlistId) {
        return playlist;
      }

      return playlist.copyWith(
        songs: playlist.songs
            .where((song) => song.id != songId)
            .toList(),
      );
    }).toList();

    await _persist();
  }

  Future<void> renamePlaylist(
    String playlistId,
    String name,
  ) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) return;

    state = state.map((playlist) {
      if (playlist.id != playlistId) {
        return playlist;
      }

      return playlist.copyWith(
        name: trimmedName,
      );
    }).toList();

    await _persist();
  }

  Future<void> _persist() {
    return StorageService.save(
      StorageService.playlistsKey,
      state.map((playlist) => playlist.toJson()).toList(),
    );
  }
}

final playlistProvider =
    NotifierProvider<PlaylistNotifier, List<FlutePlaylist>>(
  PlaylistNotifier.new,
);