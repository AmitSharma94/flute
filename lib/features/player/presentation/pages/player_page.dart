import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../music/presentation/widgets/song_artwork.dart';
import '../widgets/player_seek_bar.dart';

import '../../providers/current_song_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/player_state_provider.dart';
import '../../providers/queue_controller_provider.dart';

class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);

    if (song == null) {
      return const Scaffold(
        body: Center(
          child: Text("No song selected"),
        ),
      );
    }

    final player = ref.read(audioPlayerProvider);
    final queueController = ref.read(queueControllerProvider);
    final playerState = ref.watch(playerStateProvider);

    return Scaffold(
      body: SafeArea(
        child: playerState.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),

          error: (e, _) =>
              Center(child: Text(e.toString())),

          data: (state) {
            return Column(
              children: [

                const SizedBox(height: 12),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12),

                  child: Row(
                    children: [

                      // CLOSE PLAYER
                      IconButton(
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                        ),
                        iconSize: 40,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                      const Spacer(),

                      Text(
                        "NOW PLAYING",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge,
                      ),

                      const Spacer(),

                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Hero(
                  tag: song.id,
                  child: SongArtwork(
                    id: song.id,
                    size: 320,
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24),

                  child: Row(
                    children: [

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              song.title,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              song.artist,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,

                              style: TextStyle(
                                fontSize: 17,
                                color:
                                    Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.favorite_border,
                          size: 30,
                        ),
                        onPressed: () {},
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20),
                  child: PlayerSeekBar(),
                ),

                const Spacer(),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30),

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [

                      IconButton(
                        icon:
                            const Icon(Icons.shuffle),
                        onPressed: () {},
                      ),

                      // PREVIOUS SONG
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous,
                        ),
                        iconSize: 40,
                        onPressed: () {
                          queueController.previous();
                        },
                      ),

                      FilledButton(
                        style:
                            FilledButton.styleFrom(
                          shape:
                              const CircleBorder(),
                          padding:
                              const EdgeInsets.all(22),
                        ),

                        onPressed: () {

                          if (state.playing) {
                            player.pause();
                          } else {
                            player.resume();
                          }

                        },

                        child: Icon(
                          state.playing
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 38,
                        ),
                      ),


                      // NEXT SONG
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next,
                        ),
                        iconSize: 40,
                        onPressed: () {
                          queueController.next();
                        },
                      ),


                      IconButton(
                        icon:
                            const Icon(Icons.repeat),
                        onPressed: () {},
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28),

                  child: Row(
                    children: [

                      TextButton.icon(
                        onPressed: () {},
                        icon:
                            const Icon(Icons.queue_music),
                        label:
                            const Text("Queue"),
                      ),

                      const Spacer(),

                      TextButton.icon(
                        onPressed: () {},
                        icon:
                            const Icon(Icons.lyrics),
                        label:
                            const Text("Lyrics"),
                      ),

                    ],
                  ),
                ),

                const Divider(),

                Expanded(
                  child: Center(
                    child: Text(
                      "Lyrics will be available in a future update.",
                      style: TextStyle(
                        color:
                            Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),

              ],
            );
          },
        ),
      ),
    );
  }
}