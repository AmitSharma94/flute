import 'package:just_audio/just_audio.dart';

import '../../features/player/data/services/audio_player_service.dart';

/// Legacy compatibility adapter.
///
/// It delegates to Flute's single [AudioPlayerService] instead of creating a
/// second AudioPlayer instance.
class FluteAudioHandler {
  FluteAudioHandler(this._service);

  final AudioPlayerService _service;

  Future<void> playSong(
    String path, {
    String? title,
    String? artist,
  }) =>
      _service.loadAndPlay(path);

  Future<void> play() => _service.resume();
  Future<void> pause() => _service.pause();
  Future<void> stop() => _service.stop();
  Future<void> seek(Duration position) => _service.seek(position);

  Stream<PlayerState> get playerStateStream => _service.playerStateStream;
  Stream<Duration> get positionStream => _service.positionStream;
  Duration? get duration => _service.duration;
}
