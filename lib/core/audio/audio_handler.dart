import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:home_widget/home_widget.dart';
import 'package:just_audio/just_audio.dart';

import '../../features/music/data/models/song_model.dart';
import '../../features/player/data/services/audio_player_service.dart';

/// Bridges Flute's single just_audio engine to Android/iOS media controls.
class FluteAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  FluteAudioHandler() : service = AudioPlayerService() {
    _eventSubscription = service.playbackEventStream.listen(
      (_) => _broadcastState(),
      onError: (Object error, StackTrace stackTrace) {
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
    _stateSubscription = service.playerStateStream.listen((_) {
      _broadcastState();
      unawaited(_updateHomeWidget());
    });
  }

  final AudioPlayerService service;

  Future<void> Function()? onPlayRequested;
  Future<void> Function()? onPauseRequested;
  Future<void> Function()? onStopRequested;
  Future<void> Function()? onNextRequested;
  Future<void> Function()? onPreviousRequested;
  Future<void> Function(Duration position)? onSeekRequested;
  Future<void> Function(AudioServiceRepeatMode mode)? onRepeatRequested;
  Future<void> Function(AudioServiceShuffleMode mode)? onShuffleRequested;
  Future<void> Function(int index)? onQueueItemRequested;

  late final StreamSubscription<PlaybackEvent> _eventSubscription;
  late final StreamSubscription<PlayerState> _stateSubscription;
  int _queueIndex = 0;

  void bind({
    required Future<void> Function() play,
    required Future<void> Function() pause,
    required Future<void> Function() stop,
    required Future<void> Function() next,
    required Future<void> Function() previous,
    required Future<void> Function(Duration position) seek,
    required Future<void> Function(AudioServiceRepeatMode mode) repeat,
    required Future<void> Function(AudioServiceShuffleMode mode) shuffle,
    required Future<void> Function(int index) queueItem,
  }) {
    onPlayRequested = play;
    onPauseRequested = pause;
    onStopRequested = stop;
    onNextRequested = next;
    onPreviousRequested = previous;
    onSeekRequested = seek;
    onRepeatRequested = repeat;
    onShuffleRequested = shuffle;
    onQueueItemRequested = queueItem;
  }

  void unbind() {
    onPlayRequested = null;
    onPauseRequested = null;
    onStopRequested = null;
    onNextRequested = null;
    onPreviousRequested = null;
    onSeekRequested = null;
    onRepeatRequested = null;
    onShuffleRequested = null;
    onQueueItemRequested = null;
  }

  Future<void> setFluteQueue(
    List<FluteSong> songs, {
    required int currentIndex,
  }) async {
    _queueIndex = currentIndex.clamp(0, songs.isEmpty ? 0 : songs.length - 1);
    queue.add(songs.map(_toMediaItem).toList(growable: false));
    if (songs.isNotEmpty) {
      mediaItem.add(_toMediaItem(songs[_queueIndex]));
    }
    _broadcastState();
    await _updateHomeWidget();
  }

  Future<void> setCurrentSong(FluteSong song, int index) async {
    _queueIndex = index;
    mediaItem.add(_toMediaItem(song));
    _broadcastState();
    await _updateHomeWidget();
  }

  Future<void> setRepeatState(AudioServiceRepeatMode mode) async {
    playbackState.add(playbackState.value.copyWith(repeatMode: mode));
  }

  Future<void> setShuffleState(AudioServiceShuffleMode mode) async {
    playbackState.add(playbackState.value.copyWith(shuffleMode: mode));
  }

  @override
  Future<void> play() async {
    if (onPlayRequested != null) {
      await onPlayRequested!();
    } else {
      await service.resume();
    }
  }

  @override
  Future<void> pause() async {
    if (onPauseRequested != null) {
      await onPauseRequested!();
    } else {
      await service.pause();
    }
  }

  @override
  Future<void> stop() async {
    if (onStopRequested != null) {
      await onStopRequested!();
    } else {
      await service.stop();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    if (onSeekRequested != null) {
      await onSeekRequested!(position);
    } else {
      await service.seek(position);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (onNextRequested != null) {
      await onNextRequested!();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (onPreviousRequested != null) {
      await onPreviousRequested!();
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (onQueueItemRequested != null) {
      await onQueueItemRequested!(index);
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    if (onRepeatRequested != null) {
      await onRepeatRequested!(repeatMode);
    }
    await setRepeatState(repeatMode);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (onShuffleRequested != null) {
      await onShuffleRequested!(shuffleMode);
    }
    await setShuffleState(shuffleMode);
  }

  MediaItem _toMediaItem(FluteSong song) {
    final artwork = song.artworkUrl == null
        ? null
        : Uri.tryParse(song.artworkUrl!);
    return MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration > 0
          ? Duration(milliseconds: song.duration)
          : null,
      artUri: artwork,
      extras: <String, dynamic>{'path': song.path, 'source': song.source.name},
    );
  }

  void _broadcastState() {
    final player = service.player;
    playbackState.add(
      PlaybackState(
        controls: <MediaControl>[
          MediaControl.skipToPrevious,
          if (player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const <MediaAction>{
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.setRepeatMode,
          MediaAction.setShuffleMode,
        },
        androidCompactActionIndices: const <int>[0, 1, 2],
        processingState: _mapProcessingState(player.processingState),
        playing: player.playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: _queueIndex,
        repeatMode: playbackState.value.repeatMode,
        shuffleMode: playbackState.value.shuffleMode,
      ),
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    return switch (state) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };
  }

  Future<void> _updateHomeWidget() async {
    final current = mediaItem.value;
    await Future.wait(<Future<bool?>>[
      HomeWidget.saveWidgetData<String>(
        'flute_widget_title',
        current?.title ?? 'Nothing playing',
      ),
      HomeWidget.saveWidgetData<String>(
        'flute_widget_artist',
        current?.artist ?? 'Open flute to play music',
      ),
      HomeWidget.saveWidgetData<bool>(
        'flute_widget_playing',
        service.isPlaying,
      ),
    ]);
    await HomeWidget.updateWidget(name: 'FlutePlayerWidgetProvider');
  }

  Future<void> disposeHandler() async {
    await _eventSubscription.cancel();
    await _stateSubscription.cancel();
    await service.dispose();
  }
}
