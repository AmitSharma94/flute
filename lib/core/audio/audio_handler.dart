import 'package:just_audio/just_audio.dart';

class FluteAudioHandler {
  final AudioPlayer player = AudioPlayer();

  Future<void> playSong(
    String path, {
    String? title,
    String? artist,
  }) async {
    await player.setFilePath(path);
    await player.play();
  }

  Future<void> play() async {
    await player.play();
  }

  Future<void>pause() async {
    await player.pause();
  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  Stream<PlayerState> get playerStateStream =>
      player.playerStateStream;

  Stream<Duration> get positionStream =>
      player.positionStream;

  Duration? get duration =>
      player.duration;
}