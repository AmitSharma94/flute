import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../player/providers/player_provider.dart';
import '../data/equalizer_service.dart';

final equalizerServiceProvider = Provider<EqualizerService>((ref) {
  final service = EqualizerService();
  ref.onDispose(service.release);
  return service;
});

class EqualizerNotifier extends AsyncNotifier<EqualizerState> {
  StreamSubscription<int?>? _sessionSubscription;

  @override
  Future<EqualizerState> build() async {
    final player = ref.read(audioPlayerProvider);
    _sessionSubscription = player.audioSessionIdStream.listen((sessionId) {
      unawaited(_attach(sessionId));
    });
    ref.onDispose(() => _sessionSubscription?.cancel());
    return ref.read(equalizerServiceProvider).attach(player.audioSessionId);
  }

  Future<void> _attach(int? sessionId) async {
    state = await AsyncValue.guard(
      () => ref.read(equalizerServiceProvider).attach(sessionId),
    );
  }

  Future<void> setEnabled(bool enabled) async {
    state = await AsyncValue.guard(
      () => ref.read(equalizerServiceProvider).setEnabled(enabled),
    );
  }

  Future<void> setBandLevel(int band, int level) async {
    state = await AsyncValue.guard(
      () => ref.read(equalizerServiceProvider).setBandLevel(band, level),
    );
  }

  Future<void> usePreset(int preset) async {
    state = await AsyncValue.guard(
      () => ref.read(equalizerServiceProvider).usePreset(preset),
    );
  }
}

final equalizerProvider =
    AsyncNotifierProvider<EqualizerNotifier, EqualizerState>(
      EqualizerNotifier.new,
    );
