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

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: const Icon(
          Icons.music_note,
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
            final isPlaying = snapshot.data ?? false;

            return IconButton(
              icon: Icon(
                isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
              onPressed: () {
                if (isPlaying) {
                  player.pause();
                } else {
                  player.resume();
                }
              },
            );
          },
        ),
      ),
    );
  }
}