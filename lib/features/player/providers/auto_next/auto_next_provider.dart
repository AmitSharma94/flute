import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../player_provider.dart';
import '../queue_controller_provider.dart';


final autoNextProvider =
    Provider<void>((ref) {

  final player =
      ref.watch(
        audioPlayerProvider,
      );


  final queueController =
      ref.read(
        queueControllerProvider,
      );



  player.playerStateStream.listen(
    (state) {


      if (state.processingState ==
          ProcessingState.completed) {


        queueController.next();


      }


    },
  );


});