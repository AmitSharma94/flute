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
}

final queueProvider = NotifierProvider<QueueNotifier, List<FluteSong>>(
  QueueNotifier.new,
);
