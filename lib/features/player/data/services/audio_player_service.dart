import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer player = AudioPlayer();

  Stream<PlayerState> get playerStateStream =>
      player.playerStateStream;

  Stream<Duration> get positionStream =>
      player.positionStream;

  Stream<Duration?> get durationStream =>
      player.durationStream;

  Future<void> play(String path) async {
    await player.setFilePath(path);
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