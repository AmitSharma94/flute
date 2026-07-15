import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class FluteAudioHandler extends BaseAudioHandler {

  final AudioPlayer player = AudioPlayer();


  FluteAudioHandler() {

    player.playbackEventStream.listen((event) {

      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.play,
            MediaControl.pause,
            MediaControl.skipToNext,
          ],

          playing: player.playing,

          processingState:
              AudioProcessingState.ready,
        ),
      );

    });

  }


  Future<void> playSong(
  String path, {
  String? title,
  String? artist,
}) async {

  mediaItem.add(
    MediaItem(
      id: path,
      title: title ?? 'Unknown Song',
      artist: artist ?? 'Unknown Artist',
    ),
  );

  await player.setFilePath(path);

  await player.play();
}


  @override
  Future<void> play() =>
      player.play();


  @override
  Future<void> pause() =>
      player.pause();


  @override
  Future<void> stop() =>
      player.stop();


  @override
  Future<void> skipToNext() async {

  }


  @override
  Future<void> skipToPrevious() async {

  }

}