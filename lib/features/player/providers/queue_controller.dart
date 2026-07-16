import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'current_song_provider.dart';
import 'queue_index_provider.dart';
import 'queue_provider.dart';
import 'player_provider.dart';

import 'repeat/repeat_provider.dart';
import 'shuffle/shuffle_provider.dart';


class QueueController {

  final Ref ref;


  QueueController(this.ref);



  Future<void> playIndex(int newIndex) async {

    final queue =
        ref.read(queueProvider);


    if (queue.isEmpty) return;


    if (newIndex < 0 ||
        newIndex >= queue.length) {

      return;

    }


    ref
        .read(queueIndexProvider.notifier)
        .setIndex(newIndex);



    ref
        .read(currentSongProvider.notifier)
        .setSong(
          queue[newIndex],
        );



    await ref
        .read(audioPlayerProvider)
        .play(
          queue[newIndex].path,
        );

  }





  Future<void> next() async {


    final queue =
        ref.read(queueProvider);


    final index =
        ref.read(queueIndexProvider);



    final repeat =
        ref.read(repeatProvider);



    final shuffle =
        ref.read(shuffleProvider);



    if (queue.isEmpty) return;




    // Repeat one

    if (repeat == FluteRepeatMode.one) {


      await ref
          .read(audioPlayerProvider)
          .play(
            queue[index].path,
          );


      return;

    }




    // Shuffle

    if (shuffle &&
        queue.length > 1) {


      final random =
          Random();


      int nextIndex =
          random.nextInt(
            queue.length,
          );



      while (
        nextIndex == index
      ) {

        nextIndex =
            random.nextInt(
              queue.length,
            );

      }



      await playIndex(
        nextIndex,
      );


      return;

    }





    // Normal next

    if (index < queue.length - 1) {


      await playIndex(
        index + 1,
      );


      return;

    }




    // Repeat all

    if (repeat == FluteRepeatMode.all) {


      await playIndex(
        0,
      );


    }


  }





  Future<void> previous() async {


    final queue =
        ref.read(queueProvider);


    final index =
        ref.read(queueIndexProvider);



    if (queue.isEmpty) return;




    if (index > 0) {


      await playIndex(
        index - 1,
      );


    }


  }

}