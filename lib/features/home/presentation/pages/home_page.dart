import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../music/providers/music_provider.dart';
import '../../../player/providers/current_song_provider.dart';
import '../../../player/providers/player_provider.dart';
import '../../../player/providers/queue_index_provider.dart';
import '../../../player/providers/queue_provider.dart';

import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/song_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flute"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: songsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (e, _) =>
            Center(child: Text("Error: $e")),

        data: (songs) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Good Evening 👋",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 8),

                    Text("${songs.length} Songs"),

                  ],
                ),
              ),

              const SectionTitle(
                title: "Recently Played",
              ),

              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  itemCount:
                      songs.length > 5
                          ? 5
                          : songs.length,
                  itemBuilder:
                      (context, index) {
                    final song = songs[index];

                    return Card(
                      child: SizedBox(
                        width: 120,
                        child: Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(8),
                            child: Text(
                              song.title,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              textAlign:
                                  TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SectionTitle(
                title: "All Songs",
              ),

              ...List.generate(
                songs.length,
                (index) {

                  final song = songs[index];

                  return SongTile(

                    song: song,

                    onTap: () async {

                      ref
                          .read(
                            queueProvider.notifier,
                          )
                          .setQueue(songs);

                      ref
                          .read(
                            queueIndexProvider
                                .notifier,
                          )
                          .setIndex(index);

                      ref
                          .read(
                            currentSongProvider
                                .notifier,
                          )
                          .setSong(song);

                      final player =
                          ref.read(
                        audioPlayerProvider,
                      );

                      await player.play(
                        song.path,
                      );
                    },
                  );
                },
              ),

            ],
          );
        },
      ),
    );
  }
}