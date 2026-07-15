import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

        return Container(

          height: 80,


          margin:
              const EdgeInsets.all(12),


          padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
              ),


          decoration: BoxDecoration(

            color:
                Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,


            borderRadius:
                BorderRadius.circular(18),

          ),



          child: Row(

            children: [


              SongArtwork(

                id: song.id,

                size: 55,

              ),



              const SizedBox(
                width: 12,
              ),



              Expanded(

                child: Column(

                  mainAxisAlignment:
                      MainAxisAlignment.center,


                  crossAxisAlignment:
                      CrossAxisAlignment.start,


                  children: [


                    Text(

                      song.title,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,


                      style:
                          const TextStyle(

                            fontWeight:
                                FontWeight.bold,

                          ),

                    ),



                    Text(

                      song.artist,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                    ),


                  ],

                ),

              ),



              IconButton(

                icon: Icon(

                  state.playing

                      ? Icons.pause_circle

                      : Icons.play_circle,

                  size: 42,

                ),



                onPressed: () {


                  final player =
                      ref.read(
                        audioPlayerProvider,
                      );


                  if (state.playing) {

                    player.pause();

                  } else {

                    player.resume();

                  }


                },


              ),



            ],

          ),


        );


      },


    );


  }


}