import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/player_page.dart';

import '../../../music/presentation/widgets/song_artwork.dart';

import '../../providers/current_song_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/player_state_provider.dart';


class MiniPlayer extends ConsumerWidget {

  const MiniPlayer({
    super.key,
  });



  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {


    final song =
        ref.watch(currentSongProvider);



    if (song == null) {

      return const SizedBox.shrink();

    }



    final playerState =
        ref.watch(playerStateProvider);



    return playerState.when(

      loading: () =>
          const SizedBox.shrink(),



      error: (_, _) =>
          const SizedBox.shrink(),



      data: (state) {


        return GestureDetector(

          onTap: () {


            Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) =>
                    const PlayerPage(),

              ),

            );


          },



          child: Container(

            height:
                74,


            margin:
                const EdgeInsets.fromLTRB(
                  12,
                  0,
                  12,
                  12,
                ),



            padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                ),



            decoration:
                BoxDecoration(


              color:
                  Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,



              borderRadius:
                  BorderRadius.circular(
                    22,
                  ),



            ),



            child:
                Row(

              children: [



                ClipRRect(

                  borderRadius:
                      BorderRadius.circular(
                        12,
                      ),


                  child:
                      SongArtwork(

                    id:
                        song.id,


                    size:
                        52,

                  ),

                ),




                const SizedBox(
                  width: 12,
                ),




                Expanded(

                  child:
                      Column(

                    mainAxisAlignment:
                        MainAxisAlignment.center,


                    crossAxisAlignment:
                        CrossAxisAlignment.start,



                    children: [



                      Text(

                        song.title,


                        maxLines:
                            1,


                        overflow:
                            TextOverflow.ellipsis,



                        style:
                            const TextStyle(

                          fontWeight:
                              FontWeight.w600,


                          fontSize:
                              15,

                        ),

                      ),




                      const SizedBox(
                        height: 3,
                      ),




                      Text(

                        song.artist,


                        maxLines:
                            1,


                        overflow:
                            TextOverflow.ellipsis,



                        style:
                            TextStyle(

                          fontSize:
                              13,


                          color:
                              Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,

                        ),

                      ),



                    ],

                  ),

                ),




                IconButton(

                  icon:
                      Icon(

                    state.playing

                        ? Icons.pause_circle_filled

                        : Icons.play_circle_fill,


                    size:
                        42,

                  ),



                  onPressed: () {


                    final player =
                        ref.read(
                          audioPlayerProvider,
                        );



                    if (state.playing) {

                      player.pause();

                    }

                    else {

                      player.resume();

                    }


                  },


                ),



              ],

            ),

          ),

        );


      },

    );


  }

}