import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/player/providers/player_provider.dart';
import '../../features/player/providers/player_state_provider.dart';

class MiniPlayer extends ConsumerWidget {

  const MiniPlayer({
    super.key,
  });


  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
  ) {

    final state =
        ref.watch(playerStateProvider);


    return state.when(

      loading: () => const SizedBox(),

      error: (_, _) => const SizedBox(),

      data: (playerState) {

        final playing =
            playerState.playing;


        return Container(

          margin:
              const EdgeInsets.all(12),

          padding:
              const EdgeInsets.all(12),

          decoration: BoxDecoration(

            color:
                Colors.deepPurple.shade700,

            borderRadius:
                BorderRadius.circular(20),

          ),

          child: Row(

            children: [

              const Icon(
                Icons.music_note,
                size: 40,
              ),


              const Expanded(

                child: Text(
                  "Playing Song",
                  style:
                      TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),

              ),


              IconButton(

                icon: Icon(

                  playing
                      ? Icons.pause
                      : Icons.play_arrow,

                ),

                onPressed: () {

                  final player =
                      ref.read(
                        audioPlayerProvider,
                      );


                  playing
                      ? player.pause()
                      : player.resume();

                },

              ),

            ],

          ),

        );

      },

    );

  }

}