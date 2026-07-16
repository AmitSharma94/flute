import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../music/providers/music_provider.dart';
import '../../../music/presentation/widgets/song_artwork.dart';

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
    } 
    else if (hour >= 12 && hour < 17) {
      return "Good Afternoon 👋";
    } 
    else if (hour >= 17 && hour < 21) {
      return "Good Evening 👋";
    } 
    else {
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


        error: (e, _) => Center(
          child: Text(
            "Error: $e",
          ),
        ),



        data: (songs) {


          return ListView(

            padding: const EdgeInsets.only(
              bottom: 120,
            ),


            children: [



              Padding(

                padding: const EdgeInsets.all(20),


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

                height: 190,


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


                    return Container(

                      width: 150,


                      margin:
                          const EdgeInsets.only(
                            right: 14,
                          ),


                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,


                        children: [


                          SongArtwork(

                            id: song.id,

                            size: 150,

                          ),



                          const SizedBox(
                            height: 8,
                          ),



                          Text(

                            song.title,

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),

                          ),



                          Text(

                            song.artist,

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style:
                                TextStyle(
                              color:
                                  Colors.grey.shade500,
                            ),

                          ),


                        ],
                      ),
                    );

                  },

                ),

              ),






              const SectionTitle(
                title: "Recently Played",
              ),



              SizedBox(

                height: 160,


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



                    return Container(

                      width: 120,


                      margin:
                          const EdgeInsets.only(
                            right: 12,
                          ),


                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,


                        children: [


                          SongArtwork(

                            id: song.id,

                            size: 120,

                          ),



                          const SizedBox(
                            height: 6,
                          ),



                          Text(

                            song.title,

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                          ),


                        ],

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