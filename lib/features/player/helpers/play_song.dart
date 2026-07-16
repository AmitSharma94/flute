import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../music/data/models/song_model.dart';

import '../providers/player_provider.dart';
import '../providers/current_song_provider.dart';
import '../providers/queue_index_provider.dart';
import '../providers/queue_provider.dart';

Future<void> playSong(
  WidgetRef ref,
  List<FluteSong> queue,
  int index,
) async {
  final song = queue[index];

  ref.read(queueProvider.notifier).setQueue(queue);

  ref.read(queueIndexProvider.notifier).setIndex(index);

  ref.read(currentSongProvider.notifier).setSong(song);

  final player = ref.read(audioPlayerProvider);

  await player.play(song.path);
}