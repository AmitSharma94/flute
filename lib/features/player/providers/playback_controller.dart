import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/audio/providers/audio_handler_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../music/data/models/song_model.dart';
import '../../music/providers/music_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/services/playback_session_service.dart';
import 'current_song_provider.dart';
import 'player_provider.dart';
import 'queue_index_provider.dart';
import 'queue_provider.dart';
import 'repeat/repeat_provider.dart';
import 'shuffle/shuffle_provider.dart';

class PlaybackErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setError(String message) => state = message;
  void clear() => state = null;
}

final playbackErrorProvider = NotifierProvider<PlaybackErrorNotifier, String?>(
  PlaybackErrorNotifier.new,
);

class PlaybackBusyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setBusy(bool value) => state = value;
}

final playbackBusyProvider = NotifierProvider<PlaybackBusyNotifier, bool>(
  PlaybackBusyNotifier.new,
);

class PlaybackController {
  PlaybackController(this.ref) {
    final service = ref.read(audioPlayerProvider);
    final handler = ref.read(audioHandlerProvider);

    handler.bind(
      play: _systemPlay,
      pause: pause,
      stop: stop,
      next: next,
      previous: previous,
      seek: seek,
      repeat: _setSystemRepeat,
      shuffle: _setSystemShuffle,
      queueItem: playIndex,
      mediaId: _playMediaId,
    );

    _playerSubscription = service.playerStateStream.listen(_onPlayerState);
    _positionSubscription = service.positionStream.listen(_onPositionChanged);
    _eventSubscription = service.playbackEventStream.listen(
      (_) {},
      onError: _onStreamError,
    );

    ref.listen<FluteRepeatMode>(repeatProvider, (_, next) {
      unawaited(service.setRepeatOne(next == FluteRepeatMode.one));
      unawaited(
        handler.setRepeatState(switch (next) {
          FluteRepeatMode.off => AudioServiceRepeatMode.none,
          FluteRepeatMode.one => AudioServiceRepeatMode.one,
          FluteRepeatMode.all => AudioServiceRepeatMode.all,
        }),
      );
    });

    ref.listen<bool>(shuffleProvider, (_, next) {
      unawaited(
        handler.setShuffleState(
          next ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
        ),
      );
    });

    unawaited(_restoreSession());
  }

  final Ref ref;
  final Random _random = Random();
  final PlaybackSessionService _sessionService = PlaybackSessionService();

  late final StreamSubscription<PlayerState> _playerSubscription;
  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<PlaybackEvent> _eventSubscription;

  bool _operationInProgress = false;
  bool _handlingCompletion = false;
  bool _restoring = false;
  int? _lastShuffleIndex;
  int _lastSavedSecond = -1;

  Future<void> dispose() async {
    ref.read(audioHandlerProvider).unbind();
    await _saveSession();
    await _playerSubscription.cancel();
    await _positionSubscription.cancel();
    await _eventSubscription.cancel();
  }

  Future<void> setQueueAndPlay(List<FluteSong> songs, int index) async {
    if (songs.isEmpty || index < 0 || index >= songs.length) return;
    ref.read(queueProvider.notifier).setQueue(List.unmodifiable(songs));
    await playIndex(index);
  }

  Future<void> playIndex(int index) async {
    final queue = ref.read(queueProvider);
    if (queue.isEmpty || index < 0 || index >= queue.length) return;

    await _runLocked(() async {
      final song = queue[index];
      ref.read(playbackErrorProvider.notifier).clear();

      try {
        await ref.read(audioPlayerProvider).loadAndPlay(song.path);

        ref.read(queueIndexProvider.notifier).setIndex(index);
        ref.read(currentSongProvider.notifier).setSong(song);
        await ref
            .read(audioHandlerProvider)
            .setFluteQueue(ref.read(queueProvider), currentIndex: index);
        await ref.read(audioHandlerProvider).setCurrentSong(song, index);
        await ref.read(historyProvider.notifier).addSong(song);
        await _saveSession(position: Duration.zero);
      } catch (error) {
        ref
            .read(playbackErrorProvider.notifier)
            .setError(_friendlyError(error, song));
      }
    });
  }

  Future<void> togglePlayPause() async {
    await _runLocked(() async {
      final service = ref.read(audioPlayerProvider);
      ref.read(playbackErrorProvider.notifier).clear();

      try {
        if (service.isPlaying) {
          await service.pause();
        } else {
          final currentSong = ref.read(currentSongProvider);
          final queue = ref.read(queueProvider);

          if (currentSong == null) {
            if (queue.isEmpty) return;

            final index = _safeCurrentIndex(queue);
            final song = queue[index];
            await service.loadAndPlay(song.path);
            ref.read(queueIndexProvider.notifier).setIndex(index);
            ref.read(currentSongProvider.notifier).setSong(song);
            await ref
                .read(audioHandlerProvider)
                .setFluteQueue(ref.read(queueProvider), currentIndex: index);
            await ref.read(audioHandlerProvider).setCurrentSong(song, index);
            await ref.read(historyProvider.notifier).addSong(song);
            await _saveSession(position: Duration.zero);
            return;
          }

          if (service.player.processingState == ProcessingState.completed) {
            await service.restart();
          } else {
            await service.resume();
          }
        }
        await _saveSession();
      } catch (error) {
        ref
            .read(playbackErrorProvider.notifier)
            .setError('Unable to change playback: $error');
      }
    });
  }

  Future<void> pause() async {
    await ref.read(audioPlayerProvider).pause();
    await _saveSession();
  }

  Future<void> resume() async {
    await ref.read(audioPlayerProvider).resume();
  }

  Future<void> stop() async {
    await ref.read(audioPlayerProvider).stop();
    await _saveSession();
  }

  Future<void> seek(Duration position) async {
    try {
      await ref.read(audioPlayerProvider).seek(position);
      await _saveSession(position: position);
    } catch (_) {
      ref
          .read(playbackErrorProvider.notifier)
          .setError('Unable to seek in this song.');
    }
  }

  Future<void> toggleShuffle() async {
    ref.read(shuffleProvider.notifier).toggle();
  }

  Future<void> toggleRepeat() async {
    ref.read(repeatProvider.notifier).toggle();
  }

  Future<void> next({bool fromCompletion = false}) async {
    final queue = ref.read(queueProvider);
    if (queue.isEmpty) return;

    final currentIndex = _safeCurrentIndex(queue);
    final repeat = ref.read(repeatProvider);
    final shuffle = ref.read(shuffleProvider);

    if (fromCompletion && repeat == FluteRepeatMode.one) {
      // just_audio already loops the current source in LoopMode.one.
      return;
    }

    if (shuffle && queue.length > 1) {
      await playIndex(_nextShuffleIndex(queue.length, currentIndex));
      return;
    }

    if (currentIndex < queue.length - 1) {
      await playIndex(currentIndex + 1);
      return;
    }

    if (repeat == FluteRepeatMode.all) {
      await playIndex(0);
      return;
    }

    await ref.read(audioPlayerProvider).seek(Duration.zero);
    await ref.read(audioPlayerProvider).pause();
    await _saveSession(position: Duration.zero);
  }

  Future<void> previous() async {
    final queue = ref.read(queueProvider);
    if (queue.isEmpty) return;

    final service = ref.read(audioPlayerProvider);
    if (service.position >= const Duration(seconds: 3)) {
      await service.restart();
      await _saveSession(position: Duration.zero);
      return;
    }

    final currentIndex = _safeCurrentIndex(queue);
    if (currentIndex > 0) {
      await playIndex(currentIndex - 1);
    } else {
      await service.restart();
      await _saveSession(position: Duration.zero);
    }
  }

  Future<void> _playMediaId(String mediaId) async {
    final library = ref.read(queueProvider);
    var songs = library;
    if (songs.isEmpty) {
      final libraryState = ref.read(musicLibraryProvider).asData?.value;
      songs = libraryState?.songs ?? const <FluteSong>[];
    }
    final index = songs.indexWhere((song) => song.id == mediaId);
    if (index < 0) return;
    await setQueueAndPlay(songs, index);
  }

  Future<void> _systemPlay() async {
    if (!ref.read(audioPlayerProvider).isPlaying) {
      await togglePlayPause();
    }
  }

  Future<void> _setSystemRepeat(AudioServiceRepeatMode mode) async {
    final mapped = switch (mode) {
      AudioServiceRepeatMode.one => FluteRepeatMode.one,
      AudioServiceRepeatMode.all ||
      AudioServiceRepeatMode.group => FluteRepeatMode.all,
      _ => FluteRepeatMode.off,
    };
    ref.read(repeatProvider.notifier).setMode(mapped);
  }

  Future<void> _setSystemShuffle(AudioServiceShuffleMode mode) async {
    ref
        .read(shuffleProvider.notifier)
        .setEnabled(mode != AudioServiceShuffleMode.none);
  }

  Future<void> _restoreSession() async {
    if (_restoring) return;
    _restoring = true;
    try {
      final settings = await ref.read(settingsProvider.future);
      ref.read(shuffleProvider.notifier).setEnabled(settings.shuffleDefault);
      ref
          .read(repeatProvider.notifier)
          .setMode(
            settings.repeatDefault ? FluteRepeatMode.all : FluteRepeatMode.off,
          );

      if (!settings.resumePlayback) return;

      final session = await _sessionService.load();
      if (session == null || session.queue.isEmpty) return;
      final safeIndex = session.index
          .clamp(0, session.queue.length - 1)
          .toInt();
      final song = session.queue[safeIndex];

      await ref
          .read(audioPlayerProvider)
          .loadPaused(song.path, position: session.position);
      ref.read(queueProvider.notifier).setQueue(session.queue);
      ref.read(queueIndexProvider.notifier).setIndex(safeIndex);
      ref.read(currentSongProvider.notifier).setSong(song);
      await ref
          .read(audioHandlerProvider)
          .setFluteQueue(session.queue, currentIndex: safeIndex);
      await ref.read(audioHandlerProvider).setCurrentSong(song, safeIndex);
    } catch (_) {
      await _sessionService.clear();
    } finally {
      _restoring = false;
    }
  }

  void _onPositionChanged(Duration position) {
    if (_restoring || ref.read(currentSongProvider) == null) return;
    final second = position.inSeconds;
    if (second == _lastSavedSecond || second % 5 != 0) return;
    _lastSavedSecond = second;
    unawaited(_saveSession(position: position));
  }

  Future<void> _saveSession({Duration? position}) async {
    if (_restoring) return;
    final queue = ref.read(queueProvider);
    final index = ref.read(queueIndexProvider);
    if (queue.isEmpty || index < 0 || index >= queue.length) return;

    await _sessionService.save(
      PlaybackSession(
        queue: queue,
        index: index,
        position: position ?? ref.read(audioPlayerProvider).position,
      ),
    );
  }

  void _onPlayerState(PlayerState state) {
    if (state.processingState != ProcessingState.completed ||
        _handlingCompletion ||
        ref.read(repeatProvider) == FluteRepeatMode.one) {
      return;
    }

    _handlingCompletion = true;
    unawaited(
      next(fromCompletion: true).whenComplete(() {
        _handlingCompletion = false;
      }),
    );
  }

  void _onStreamError(Object error, StackTrace stackTrace) {
    ref
        .read(playbackErrorProvider.notifier)
        .setError('The audio player reported an error: $error');
  }

  int _safeCurrentIndex(List<FluteSong> queue) {
    final index = ref.read(queueIndexProvider);
    return index >= 0 && index < queue.length ? index : 0;
  }

  int _nextShuffleIndex(int length, int currentIndex) {
    var nextIndex = _random.nextInt(length);
    while (nextIndex == currentIndex ||
        (length > 2 && nextIndex == _lastShuffleIndex)) {
      nextIndex = _random.nextInt(length);
    }
    _lastShuffleIndex = currentIndex;
    return nextIndex;
  }

  Future<void> _runLocked(Future<void> Function() operation) async {
    if (_operationInProgress) return;
    _operationInProgress = true;
    ref.read(playbackBusyProvider.notifier).setBusy(true);

    try {
      await operation();
    } finally {
      _operationInProgress = false;
      ref.read(playbackBusyProvider.notifier).setBusy(false);
    }
  }

  String _friendlyError(Object error, FluteSong song) {
    final value = error.toString().toLowerCase();
    if (value.contains('no longer exists') || value.contains('cannot find')) {
      return '“${song.title}” is no longer available on this device.';
    }
    if (value.contains('permission')) {
      return 'flute does not have permission to play “${song.title}”.';
    }
    return 'Unable to play “${song.title}”. The source may be unavailable or unsupported.';
  }
}

final playbackControllerProvider = Provider<PlaybackController>((ref) {
  final controller = PlaybackController(ref);
  ref.onDispose(() {
    unawaited(controller.dispose());
  });
  return controller;
});
