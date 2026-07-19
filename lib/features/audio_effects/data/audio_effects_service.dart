import 'dart:io';

import 'package:flutter/services.dart';

class AudioEffectsState {
  const AudioEffectsState({
    required this.supported,
    required this.loudnessSupported,
    required this.loudnessEnabled,
    required this.loudnessGainMb,
    required this.spatialSupported,
    required this.spatialEnabled,
    required this.spatialStrength,
  });

  const AudioEffectsState.unsupported()
    : supported = false,
      loudnessSupported = false,
      loudnessEnabled = false,
      loudnessGainMb = 0,
      spatialSupported = false,
      spatialEnabled = false,
      spatialStrength = 0;

  factory AudioEffectsState.fromMap(Map<Object?, Object?> map) {
    return AudioEffectsState(
      supported: map['supported'] as bool? ?? false,
      loudnessSupported: map['loudnessSupported'] as bool? ?? false,
      loudnessEnabled: map['loudnessEnabled'] as bool? ?? false,
      loudnessGainMb: map['loudnessGainMb'] as int? ?? 0,
      spatialSupported: map['spatialSupported'] as bool? ?? false,
      spatialEnabled: map['spatialEnabled'] as bool? ?? false,
      spatialStrength: map['spatialStrength'] as int? ?? 0,
    );
  }

  final bool supported;
  final bool loudnessSupported;
  final bool loudnessEnabled;
  final int loudnessGainMb;
  final bool spatialSupported;
  final bool spatialEnabled;
  final int spatialStrength;
}

class AudioEffectsService {
  static const _channel = MethodChannel(
    'com.amitsharma.flute/audio_effects',
  );

  Future<AudioEffectsState> attach(int? sessionId) async {
    if (!Platform.isAndroid || sessionId == null || sessionId <= 0) {
      return const AudioEffectsState.unsupported();
    }
    final result = await _channel.invokeMapMethod<Object?, Object?>('attach', {
      'audioSessionId': sessionId,
    });
    return AudioEffectsState.fromMap(result ?? const {});
  }

  Future<AudioEffectsState> setLoudness({
    required bool enabled,
    required int gainMb,
  }) async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'setLoudness',
      {'enabled': enabled, 'gainMb': gainMb.clamp(0, 600)},
    );
    return AudioEffectsState.fromMap(result ?? const {});
  }

  Future<AudioEffectsState> setSpatial({
    required bool enabled,
    required int strength,
  }) async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'setSpatial',
      {'enabled': enabled, 'strength': strength.clamp(0, 1000)},
    );
    return AudioEffectsState.fromMap(result ?? const {});
  }

  Future<bool> startVisualizer() async {
    if (!Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('startVisualizer') ?? false;
  }

  Future<List<int>> getVisualizerFrame() async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'getVisualizerFrame',
    );
    if (result?['available'] != true) return const [];
    return (result?['waveform'] as List<Object?>? ?? const [])
        .whereType<int>()
        .toList(growable: false);
  }

  Future<void> stopVisualizer() => _channel.invokeMethod<void>('stopVisualizer');
  Future<void> release() => _channel.invokeMethod<void>('release');
}
