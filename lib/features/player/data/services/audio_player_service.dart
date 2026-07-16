import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';


class AudioPlayerService {


  final AudioPlayer player =
      AudioPlayer();



  Stream<PlayerState> get playerStateStream =>
      player.playerStateStream;



  Stream<Duration> get positionStream =>
      player.positionStream;



  Stream<Duration?> get durationStream =>
      player.durationStream;



  Future<void> play({

    required String path,

    required String title,

    required String artist,

    required String id,

  }) async {


    await player.setAudioSource(

      AudioSource.file(

        path,

        tag: MediaItem(

          id: id,

          title: title,

          artist: artist,

        ),

      ),

    );


    await player.play();

  }




  Future<void> pause() async {

    await player.pause();

  }




  Future<void> resume() async {

    await player.play();

  }




  Future<void> stop() async {

    await player.stop();

  }




  void dispose() {

    player.dispose();

  }


}