import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/shuffle/shuffle_provider.dart';
import 'queue/queue_page.dart';

import '../../../music/presentation/widgets/song_artwork.dart';

import '../widgets/player_seek_bar.dart';

import '../../providers/current_song_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/player_state_provider.dart';
import '../../providers/queue_controller_provider.dart';
import '../../providers/repeat/repeat_provider.dart';


class PlayerPage extends ConsumerWidget {

  const PlayerPage({
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

      return const Scaffold(

        body: Center(
          child:
              Text(
                "No song selected",
              ),
        ),

      );

    }



    final player =
        ref.read(audioPlayerProvider);


    final queueController =
        ref.read(queueControllerProvider);


    final playerState =
        ref.watch(playerStateProvider);



    return Scaffold(

      body: SafeArea(

        child: playerState.when(

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



          data: (state) {


            return Column(

              children: [


                Padding(

                  padding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),


                  child: Row(

                    children: [


                      IconButton(

                        icon:
                            const Icon(
                              Icons.skip_previous,
                            ),

                        iconSize:
                            40,


                        onPressed: () {

                          queueController.previous();

                        },

                      ),



                      const Spacer(),



                      const Text(
                        "NOW PLAYING",
                      ),



                      const Spacer(),



                      IconButton(

  icon:
      const Icon(
        Icons.queue_music,
      ),


  onPressed: () {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            const QueuePage(),

      ),

    );

  },

),


                    ],

                  ),

                ),




                const SizedBox(
                  height: 20,
                ),



                Hero(

                  tag:
                      song.id,


                  child:
                      SongArtwork(

                        id:
                            song.id,

                        size:
                            320,

                      ),

                ),




                const SizedBox(
                  height: 30,
                ),




                Text(

                  song.title,


                  maxLines:
                      1,


                  overflow:
                      TextOverflow.ellipsis,


                  style:
                      const TextStyle(

                    fontSize:
                        24,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),




                const SizedBox(
                  height: 5,
                ),




                Text(

                  song.artist,


                  style:
                      TextStyle(

                    color:
                        Colors.grey.shade500,

                    fontSize:
                        17,

                  ),

                ),




                const SizedBox(
                  height: 20,
                ),




                const Padding(

                  padding:
                      EdgeInsets.symmetric(
                        horizontal: 20,
                      ),

                  child:
                      PlayerSeekBar(),

                ),




                const Spacer(),




                Row(

                  mainAxisAlignment:
                      MainAxisAlignment.center,


                  children: [




                    Consumer(
  builder: (context, ref, _) {

    final shuffle =
        ref.watch(
          shuffleProvider,
        );


    return IconButton(

      icon:
          Icon(

            Icons.shuffle,

            color: shuffle
                ? Theme.of(context)
                    .colorScheme
                    .primary
                : Colors.grey,

          ),


      iconSize:
          28,


      onPressed: () {

        ref
            .read(
              shuffleProvider
                  .notifier,
            )
            .toggle();

      },

    );

  },
),




                    IconButton(

                      icon:
                          const Icon(
                            Icons.skip_previous,
                          ),

                      iconSize:
                          40,


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
                            const EdgeInsets.all(
                              22,
                            ),

                      ),



                      onPressed: () {


                        if (state.playing) {

                          player.pause();

                        }

                        else {

                          player.resume();

                        }


                      },



                      child:
                          Icon(

                            state.playing

                                ? Icons.pause

                                : Icons.play_arrow,


                            size:
                                38,

                          ),

                    ),




                    IconButton(

                      icon:
                          const Icon(
                            Icons.skip_next,
                          ),

                      iconSize:
                          40,


                      onPressed: () {

                        queueController.next();

                      },

                    ),





                    Consumer(

                      builder:
                          (context, ref, _) {


                        final repeat =
                            ref.watch(
                              repeatProvider,
                            );



                        Icon icon;



                        switch (repeat) {


                          case FluteRepeatMode.off:

                            icon =
                                const Icon(

                                  Icons.repeat,

                                  color:
                                      Colors.grey,

                                );

                            break;



                          case FluteRepeatMode.all:

                            icon =
                                const Icon(
                                  Icons.repeat,
                                );

                            break;



                          case FluteRepeatMode.one:

                            icon =
                                const Icon(
                                  Icons.repeat_one,
                                );

                            break;


                        }




                        return IconButton(

                          icon:
                              icon,


                          iconSize:
                              28,


                          onPressed: () {


                            ref
                                .read(
                                  repeatProvider
                                      .notifier,
                                )
                                .toggle();


                          },

                        );


                      },

                    ),



                  ],

                ),



                const SizedBox(
                  height: 20,
                ),



              ],

            );

          },

        ),

      ),

    );

  }

}