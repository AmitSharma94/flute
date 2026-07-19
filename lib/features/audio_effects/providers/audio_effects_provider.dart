import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../player/providers/player_provider.dart';
import '../data/audio_effects_service.dart';

final audioEffectsServiceProvider = Provider<AudioEffectsService>((ref) {
  final service = AudioEffectsService();
  ref.onDispose(service.release);
  return service;
});

class AudioEffectsNotifier extends AsyncNotifier<AudioEffectsState> {
  StreamSubscription<int?>? _sessionSubscription;

  @override
  Future<AudioEffectsState> build() async {
    final player = ref.read(audioPlayerProvider);
    _sessionSubscription = player.audioSessionIdStream.listen((sessionId) {
      unawaited(_attach(sessionId));
    });
    ref.onDispose(() => _sessionSubscription?.cancel());
    return ref.read(audioEffectsServiceProvider).attach(player.audioSessionId);
  }

  Future<void> _attach(int? sessionId) async {
    state = await AsyncValue.guard(
      () => ref.read(audioEffectsServiceProvider).attach(sessionId),
    );
  }

  Future<void> setLoudness(bool enabled, int gainMb) async {
    state = await AsyncValue.guard(
      () => ref
          .read(audioEffectsServiceProvider)
          .setLoudness(enabled: enabled, gainMb: gainMb),
    );
  }

  Future<void> setSpatial(bool enabled, int strength) async {
    state = await AsyncValue.guard(
      () => ref
          .read(audioEffectsServiceProvider)
          .setSpatial(enabled: enabled, strength: strength),
    );
  }
}

final audioEffectsProvider =
    AsyncNotifierProvider<AudioEffectsNotifier, AudioEffectsState>(
      AudioEffectsNotifier.new,
    );
