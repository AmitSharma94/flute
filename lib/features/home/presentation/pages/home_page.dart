import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../player/helpers/play_song.dart';

import '../../../music/providers/music_provider.dart';

import '../widgets/greeting_header.dart';
import '../widgets/quick_access_section.dart';
import '../widgets/cards/music_card.dart';

import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/song_tile.dart';


class HomePage extends ConsumerWidget {

  const HomePage({
    super.key,
  });


  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final songsAsync =
        ref.watch(songsProvider);


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

            icon:
                const Icon(
                  Icons.search,
                ),

            onPressed: () {},

          ),

        ],

      ),



      body: songsAsync.when(

        loading: () =>
            const Center(
              child:
                  CircularProgressIndicator(),
            ),



        error: (e, _) =>
            Center(
              child:
                  Text(
                    "Error: $e",
                  ),
            ),



        data: (songs) {


          return ListView(

            padding:
                const EdgeInsets.only(
                  bottom: 120,
                ),


            children: [


              GreetingHeader(
                songCount: songs.length,
              ),



              const QuickAccessSection(),



              const SectionTitle(
                title:
                    "Continue Listening",
              ),



              SizedBox(

                height:
                    200,


                child:
                    ListView.builder(

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


                    return Padding(

                      padding:
                          const EdgeInsets.only(
                            right: 14,
                          ),


                      child:
                          MusicCard(

                            song: song,

                            size: 150,

                          ),

                    );

                  },

                ),

              ),




              const SectionTitle(

                title:
                    "Recently Played",

              ),




              SizedBox(

                height:
                    170,


                child:
                    ListView.builder(

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



                    return Padding(

                      padding:
                          const EdgeInsets.only(
                            right: 12,
                          ),


                      child:
                          MusicCard(

                            song: song,

                            size: 120,

                          ),

                    );

                  },

                ),

              ),





              const SectionTitle(

                title:
                    "All Songs",

              ),




              ...List.generate(

                songs.length,


                (index) {


                  final song =
                      songs[index];



                  return SongTile(

                    song: song,


                    onTap: () async {


                      await playSong(

                        ref,

                        songs,

                        index,

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