import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_service.dart';
import '../../music/data/models/song_model.dart';

class FavoriteNotifier extends Notifier<List<FluteSong>> {
  bool _loaded = false;

  @override
  List<FluteSong> build() {
    if (!_loaded) {
      _loaded = true;
      Future<void>.microtask(_loadFavorites);
    }
    return const [];
  }

  Future<void> _loadFavorites() async {
    try {
      final data = await StorageService.load(StorageService.favoritesKey);
      final loaded = data
          .whereType<Map>()
          .map((item) => FluteSong.fromJson(Map<String, dynamic>.from(item)))
          .where((song) => song.id.isNotEmpty)
          .toList();

      final current = state;
      state = [
        ...current,
        ...loaded.where((song) => current.every((item) => item != song)),
      ];
    } catch (_) {
      // Keep any in-memory changes if stored data is unavailable.
    }
  }

  Future<void> toggle(FluteSong song) async {
    if (state.contains(song)) {
      state = state.where((item) => item != song).toList();
    } else {
      state = [...state, song];
    }
    await _persist();
  }

  Future<void> removeUnavailable(Set<String> availableIds) async {
    final cleaned = state.where((song) => availableIds.contains(song.id)).toList();
    if (cleaned.length == state.length) return;
    state = cleaned;
    await _persist();
  }

  Future<void> _persist() => StorageService.save(
        StorageService.favoritesKey,
        state.map((song) => song.toJson()).toList(),
      );
}

final favoriteProvider =
    NotifierProvider<FavoriteNotifier, List<FluteSong>>(FavoriteNotifier.new);
