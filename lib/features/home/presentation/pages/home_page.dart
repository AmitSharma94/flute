import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../music/providers/music_provider.dart';
import '../../../player/providers/player_provider.dart';
import '../../../../shared/widgets/mini_player.dart';
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

    final songs =
        ref.watch(songsProvider);


    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Flute",
        ),
      ),


      body: songs.when(

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


          return Column(

            children: [


              Expanded(

                child: ListView.builder(

                  itemCount:
                      songs.length,


                  itemBuilder:
                      (context,index) {


                    final song =
                        songs[index];


                    return SongTile(

                      song:
                          song,


                      onTap: () async {


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

              ),


              const MiniPlayer(),


            ],

          );


        },

      ),

    );

  }

}