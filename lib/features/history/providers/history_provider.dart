import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_service.dart';
import '../../music/data/models/song_model.dart';

class HistoryNotifier extends Notifier<List<FluteSong>> {
  bool _loaded = false;

  @override
  List<FluteSong> build() {
    if (!_loaded) {
      _loaded = true;
      Future<void>.microtask(_loadHistory);
    }
    return [];
  }

  Future<void> _loadHistory() async {
    try {
      final data = await StorageService.load(StorageService.historyKey);
      final loaded = data
          .whereType<Map>()
          .map((item) => FluteSong.fromJson(Map<String, dynamic>.from(item)))
          .where((song) => song.id.isNotEmpty)
          .toList();
      final current = state;
      state = [
        ...current,
        ...loaded.where((song) => current.every((item) => item != song)),
      ].take(20).toList();
    } catch (_) {
      // Keep any in-memory history if stored data cannot be read.
    }
  }

  Future<void> addSong(FluteSong song) async {
    state = [song, ...state.where((item) => item != song)];
    if (state.length > 20) {
      state = state.sublist(0, 20);
    }

    await StorageService.save(
      StorageService.historyKey,
      state.map((item) => item.toJson()).toList(),
    );
  }

  Future<void> removeUnavailable(Set<String> availableIds) async {
    final cleaned = state.where((song) => song.isOnline || availableIds.contains(song.id)).toList();
    if (cleaned.length == state.length) return;
    state = cleaned;
    await StorageService.save(
      StorageService.historyKey,
      state.map((item) => item.toJson()).toList(),
    );
  }

  Future<void> clearHistory() async {
    state = [];
    await StorageService.save(StorageService.historyKey, const []);
  }
}

final historyProvider =
    NotifierProvider<HistoryNotifier, List<FluteSong>>(HistoryNotifier.new);
