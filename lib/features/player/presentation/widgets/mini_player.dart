import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/current_song_provider.dart';
import '../../providers/player_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);

    if (song == null) {
      return const SizedBox.shrink();
    }

    final player = ref.read(audioPlayerProvider);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/player',
        );
      },

      child: Card(
        margin: const EdgeInsets.all(8),
        elevation: 3,

        child: ListTile(
          leading: const Icon(
            Icons.library_music_rounded,
            size: 40,
          ),

          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          subtitle: Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          trailing: StreamBuilder<bool>(
            stream: player.player.playingStream,

            builder: (context, snapshot) {
              final playing =
                  snapshot.data ?? false;

              return IconButton(
                icon: Icon(
                  playing
                      ? Icons.pause_circle
                      : Icons.play_circle,
                  size: 36,
                ),

                onPressed: () {
                  if (playing) {
                    player.pause();
                  } else {
                    player.resume();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}