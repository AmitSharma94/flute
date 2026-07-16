import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../music/providers/music_provider.dart';
import '../../../music/presentation/widgets/song_artwork.dart';

import '../../../player/helpers/play_song.dart';

import '../../../../shared/widgets/song_tile.dart';
import '../../../../shared/widgets/section_title.dart';

import '../widgets/greeting_header.dart';
import '../widgets/quick_access_section.dart';



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
        ref.watch(
          songsProvider,
        );



    return Scaffold(


      body:
          SafeArea(


        child:
            songsAsync.when(


          loading: () =>
              const Center(

                child:
                    CircularProgressIndicator(),

              ),



          error: (e, _) =>
              Center(

                child:
                    Text(
                      e.toString(),
                    ),

              ),




          data: (songs) {



            return ListView(


              padding:
                  const EdgeInsets.only(
                    bottom: 120,
                  ),



              children: [



                const SizedBox(
                  height: 20,
                ),



                GreetingHeader(
                  songCount:
                      songs.length,
                ),




                const SizedBox(
                  height: 20,
                ),



                const QuickAccessSection(),




                const SizedBox(
                  height: 25,
                ),





                const SectionTitle(
                  title:
                      "Continue Listening",
                ),




                SizedBox(

                  height:
                      190,


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



                      return GestureDetector(


                        onTap: () {


                          playSong(
                            ref,
                            songs,
                            index,
                          );


                        },



                        child:
                            Container(


                          width:
                              150,



                          margin:
                              const EdgeInsets.only(
                                right: 14,
                              ),




                          child:
                              Column(


                            crossAxisAlignment:
                                CrossAxisAlignment.start,



                            children: [



                              SongArtwork(

                                id:
                                    song.id,

                                size:
                                    150,

                              ),



                              const SizedBox(
                                height: 8,
                              ),



                              Text(

                                song.title,


                                maxLines:
                                    1,


                                overflow:
                                    TextOverflow.ellipsis,



                                style:
                                    const TextStyle(

                                  fontWeight:
                                      FontWeight.w700,

                                ),

                              ),



                              Text(

                                song.artist,


                                maxLines:
                                    1,


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

                        ),

                      );


                    },

                  ),

                ),





                const SizedBox(
                  height: 20,
                ),




                const SectionTitle(
                  title:
                      "All Songs",
                ),




                ...List.generate(

                  songs.length,


                  (index) {


                    return SongTile(

                      song:
                          songs[index],


                      onTap: () {


                        playSong(

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

      ),

    );


  }

}