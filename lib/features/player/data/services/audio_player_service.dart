import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';

/// The single audio engine used by Flute.
class AudioPlayerService {
  AudioPlayerService() : player = AudioPlayer();

  final AudioPlayer player;

  Stream<PlayerState> get playerStateStream => player.playerStateStream;
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Stream<PlaybackEvent> get playbackEventStream => player.playbackEventStream;

  Duration get position => player.position;
  Duration? get duration => player.duration;
  bool get isPlaying => player.playing;

  Future<void> loadAndPlay(String source) async {
    await _load(source);
    _startPlayback();
  }

  Future<void> loadPaused(
    String source, {
    Duration position = Duration.zero,
  }) async {
    await _load(source);
    await seek(position);
    await player.pause();
  }

  Future<void> _load(String source) async {
    final value = source.trim();
    if (value.isEmpty) {
      throw const FileSystemException('The song has no audio source.');
    }

    final file = File(value);
    if (!await file.exists()) {
      throw FileSystemException('The audio file no longer exists.', value);
    }

    await player.setFilePath(value);
  }

  /// Starts playback without awaiting the entire track duration.
  void _startPlayback() {
    // Do not await play(): its Future completes when playback stops or ends.
    unawaited(player.play());
  }

  Future<void> play(String path) => loadAndPlay(path);
  Future<void> pause() => player.pause();

  Future<void> resume() async {
    _startPlayback();
  }

  Future<void> stop() => player.stop();

  Future<void> seek(Duration position) async {
    final total = player.duration;
    final safePosition = total == null || position <= total ? position : total;
    await player.seek(
      safePosition < Duration.zero ? Duration.zero : safePosition,
    );
  }

  Future<void> restart({bool autoplay = true}) async {
    await player.seek(Duration.zero);
    if (autoplay) {
      _startPlayback();
    }
  }

  Future<void> setRepeatOne(bool enabled) {
    return player.setLoopMode(enabled ? LoopMode.one : LoopMode.off);
  }

  Future<void> dispose() => player.dispose();
}
