import 'dart:io';

import 'package:just_audio/just_audio.dart';

/// The single audio engine used by Flute.
class AudioPlayerService {
  AudioPlayerService() : player = AudioPlayer();

  final AudioPlayer player;

  Stream<PlayerState> get playerStateStream => player.playerStateStream;
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;

  Duration get position => player.position;
  Duration? get duration => player.duration;
  bool get isPlaying => player.playing;

  Future<void> loadAndPlay(String path) async {
    if (path.trim().isEmpty) {
      throw const FileSystemException('The song has no file path.');
    }

    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('The audio file no longer exists.', path);
    }

    await player.setFilePath(path);
    await player.play();
  }


  Future<void> loadPaused(
    String path, {
    Duration position = Duration.zero,
  }) async {
    if (path.trim().isEmpty) {
      throw const FileSystemException('The song has no file path.');
    }

    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('The audio file no longer exists.', path);
    }

    await player.setFilePath(path);
    await seek(position);
    await player.pause();
  }

  /// Kept for compatibility with existing callers.
  Future<void> play(String path) => loadAndPlay(path);

  Future<void> pause() => player.pause();
  Future<void> resume() => player.play();
  Future<void> stop() => player.stop();

  Future<void> seek(Duration position) async {
    final total = player.duration;
    final safePosition = total == null || position <= total ? position : total;
    await player.seek(safePosition < Duration.zero ? Duration.zero : safePosition);
  }

  Future<void> restart({bool autoplay = true}) async {
    await player.seek(Duration.zero);
    if (autoplay) {
      await player.play();
    }
  }

  Future<void> dispose() => player.dispose();
}
