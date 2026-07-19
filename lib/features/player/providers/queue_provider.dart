import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../music/data/models/song_model.dart';

class QueueNotifier extends Notifier<List<FluteSong>> {
  @override
  List<FluteSong> build() {
    return [];
  }

  void setQueue(List<FluteSong> songs) {
    state = songs;
  }

  void removeSong(String songId) {
    state = List.unmodifiable(
      state.where((song) => song.id != songId),
    );
  }
}

final queueProvider = NotifierProvider<QueueNotifier, List<FluteSong>>(
  QueueNotifier.new,
);
