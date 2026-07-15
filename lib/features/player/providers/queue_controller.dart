import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'current_song_provider.dart';
import 'queue_index_provider.dart';
import 'queue_provider.dart';
import 'player_provider.dart';

class QueueController {

  final Ref ref;

  QueueController(this.ref);


  void next() {

    final queue = ref.read(queueProvider);
    final index = ref.read(queueIndexProvider);

    if (queue.isEmpty) return;

    if (index < queue.length - 1) {

      final nextIndex = index + 1;

      ref
          .read(queueIndexProvider.notifier)
          .setIndex(nextIndex);

      ref
          .read(currentSongProvider.notifier)
          .setSong(queue[nextIndex]);

      ref
          .read(audioPlayerProvider)
          .play(queue[nextIndex].path);
    }
  }


  void previous() {

    final queue = ref.read(queueProvider);
    final index = ref.read(queueIndexProvider);

    if (queue.isEmpty) return;

    if (index > 0) {

      final previousIndex = index - 1;

      ref
          .read(queueIndexProvider.notifier)
          .setIndex(previousIndex);

      ref
          .read(currentSongProvider.notifier)
          .setSong(queue[previousIndex]);

      ref
          .read(audioPlayerProvider)
          .play(queue[previousIndex].path);
    }
  }
}