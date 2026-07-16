import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/queue_index_provider.dart';
import '../../../providers/queue_provider.dart';

import '../../../helpers/play_song.dart';

import '../../../../../shared/widgets/song_tile.dart';



class QueuePage extends ConsumerWidget {

  const QueuePage({
    super.key,
  });



  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {


    final queue =
        ref.watch(
          queueProvider,
        );


    final currentIndex =
        ref.watch(
          queueIndexProvider,
        );



    return Scaffold(

      appBar: AppBar(

        title:
            const Text(
              "Queue",
            ),

      ),



      body: queue.isEmpty

          ? const Center(

              child:
                  Text(
                    "Queue is empty",
                  ),

            )


          : ListView.builder(

              itemCount:
                  queue.length,


              itemBuilder:
                  (context, index) {


                final song =
                    queue[index];


                return Container(

                  color:
                      index == currentIndex

                          ? Theme.of(context)
                              .colorScheme
                              .primaryContainer

                          : null,


                  child: SongTile(

                    song:
                        song,


                    onTap: () async {


                      await playSong(

                        ref,

                        queue,

                        index,

                      );


                    },

                  ),

                );


              },

            ),

    );

  }

}