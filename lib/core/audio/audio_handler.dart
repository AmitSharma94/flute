import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class FluteAudioHandler extends BaseAudioHandler {

  final AudioPlayer _player = AudioPlayer();

  FluteAudioHandler() {

    _player.playbackEventStream.listen((event) {

      playbackState.add(
        playbackState.value.copyWith(
          playing: _player.playing,
          processingState:
              AudioProcessingState.ready,
        ),
      );

    });

  }


  Future<void> playSong(String path) async {

    await _player.setFilePath(path);

    await _player.play();

  }


  @override
  Future<void> play() =>
      _player.play();


  @override
  Future<void> pause() =>
      _player.pause();


  @override
  Future<void> stop() =>
      _player.stop();

}