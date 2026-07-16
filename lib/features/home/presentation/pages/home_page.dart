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

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning 👋";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon 👋";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening 👋";
    } else {
      return "Good Night 🌙";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Flute",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),

      body: songsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (error, _) => Center(
          child: Text(
            "Error: $error",
          ),
        ),

        data: (songs) {
          return ListView(
            padding: const EdgeInsets.only(
              bottom: 120,
            ),

            children: [

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  10,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      getGreeting(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      "${songs.length} songs available",
                    ),

                  ],
                ),
              ),


              const SectionTitle(
                title: "Continue Listening",
              ),


              SizedBox(
                height: 150,

                child: ListView.builder(
                  scrollDirection:
                      Axis.horizontal,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  itemCount:
                      songs.length > 6
                          ? 6
                          : songs.length,

                  itemBuilder:
                      (context, index) {

                    final song =
                        songs[index];

                    return Card(
                      child: SizedBox(
                        width: 140,

                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            12,
                          ),

                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [

                              const Icon(
                                Icons.music_note,
                                size: 40,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Text(
                                song.title,

                                maxLines: 2,

                                overflow:
                                    TextOverflow
                                        .ellipsis,

                                textAlign:
                                    TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),



              const SectionTitle(
                title: "Recently Played",
              ),


              SizedBox(
                height: 120,

                child: ListView.builder(
                  scrollDirection:
                      Axis.horizontal,

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

                    final song =
                        songs[index];

                    return Card(
                      child: SizedBox(
                        width: 120,

                        child: Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              8,
                            ),

                            child: Text(
                              song.title,

                              maxLines: 2,

                              overflow:
                                  TextOverflow
                                      .ellipsis,

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

                  final song =
                      songs[index];

                  return SongTile(
                    song: song,

                    onTap: () async {

                      ref
                          .read(
                            queueProvider
                                .notifier,
                          )
                          .setQueue(
                            songs,
                          );


                      ref
                          .read(
                            queueIndexProvider
                                .notifier,
                          )
                          .setIndex(
                            index,
                          );


                      ref
                          .read(
                            currentSongProvider
                                .notifier,
                          )
                          .setSong(
                            song,
                          );


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