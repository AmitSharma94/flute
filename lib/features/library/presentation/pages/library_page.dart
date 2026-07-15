import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../music/providers/music_provider.dart';
import '../../../player/providers/player_provider.dart';
import '../../../player/providers/current_song_provider.dart';
import '../../../player/providers/queue_provider.dart';
import '../../../player/providers/queue_index_provider.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(songsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: songs.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('No songs found'),
            );
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final song = list[index];

              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.music_note,
                  ),
                  title: Text(song.title),
                  subtitle: Text(song.artist),
                  trailing: const Icon(
                    Icons.play_arrow,
                  ),
                  onTap: () {
                    ref
                        .read(queueProvider.notifier)
                        .setQueue(list);

                    ref
                        .read(queueIndexProvider.notifier)
                        .setIndex(index);

                    ref
                        .read(currentSongProvider.notifier)
                        .setSong(song);

                    ref
                        .read(audioPlayerProvider)
                        .play(song.path);
                  },
                ),
              );
            },
          );
        },
        error: (error, stack) {
          return Center(
            child: Text(
              error.toString(),
            ),
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}