import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/current_song_provider.dart';
import '../../providers/player_provider.dart';

class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);

    final player = ref.read(audioPlayerProvider);

    if (song == null) {
      return const Scaffold(
        body: Center(
          child: Text('No song selected'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.album,
              size: 220,
            ),

            const SizedBox(height: 30),

            Text(
              song.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            Text(
              song.artist,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),

            const SizedBox(height: 40),

            Slider(
              value: 0,
              onChanged: (_) {},
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [

                IconButton(
                  icon: const Icon(
                    Icons.skip_previous,
                    size: 40,
                  ),
                  onPressed: () {},
                ),

                StreamBuilder<bool>(
                  stream:
                      player.player.playingStream,

                  builder: (context, snapshot) {

                    final playing =
                        snapshot.data ?? false;

                    return FilledButton(
                      onPressed: () {

                        if (playing) {
                          player.pause();
                        } else {
                          player.resume();
                        }

                      },

                      child: Icon(
                        playing
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    );
                  },
                ),

                IconButton(
                  icon: const Icon(
                    Icons.skip_next,
                    size: 40,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}