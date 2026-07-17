import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/queue_provider.dart';
import '../../../providers/queue_index_provider.dart';

import '../../../../music/presentation/widgets/song_artwork.dart';

import '../../../helpers/play_song.dart';


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
        ref.watch(queueProvider);


    final currentIndex =
        ref.watch(queueIndexProvider);



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



                return ListTile(


                  leading:
                      SongArtwork(

                        id:
                            song.id,
                        imageUrl: song.artworkUrl,

                        size:
                            50,

                      ),



                  title:
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                      ),



                  subtitle:
                      Text(
                        song.artist,
                      ),



                  trailing:
                      index == currentIndex

                          ? const Icon(
                              Icons.play_arrow,
                            )

                          : null,



                  onTap: () {


                    playSong(

                      ref,

                      queue,

                      index,

                    );


                    Navigator.pop(
                      context,
                    );


                  },


                );


              },


            ),

    );


  }

}