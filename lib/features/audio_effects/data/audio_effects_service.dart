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
      supported: map['supported'] == true,
      loudnessSupported: map['loudnessSupported'] == true,
      loudnessEnabled: map['loudnessEnabled'] == true,
      loudnessGainMb: (map['loudnessGainMb'] as num?)?.toInt() ?? 0,
      spatialSupported: map['spatialSupported'] == true,
      spatialEnabled: map['spatialEnabled'] == true,
      spatialStrength: (map['spatialStrength'] as num?)?.toInt() ?? 0,
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
  static const MethodChannel _channel = MethodChannel(
    'com.amitsharma.flute/audio_effects',
  );

  Future<AudioEffectsState> attach(int? sessionId) async {
    if (!Platform.isAndroid || sessionId == null || sessionId <= 0) {
      return const AudioEffectsState.unsupported();
    }

    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'attach',
      <String, Object?>{'audioSessionId': sessionId},
    );

    return AudioEffectsState.fromMap(result ?? const <Object?, Object?>{});
  }

  Future<AudioEffectsState> setLoudness({
    required bool enabled,
    required int gainMb,
  }) async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'setLoudness',
      <String, Object?>{
        'enabled': enabled,
        'gainMb': gainMb.clamp(0, 600).toInt(),
      },
    );

    return AudioEffectsState.fromMap(result ?? const <Object?, Object?>{});
  }

  Future<AudioEffectsState> setSpatial({
    required bool enabled,
    required int strength,
  }) async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'setSpatial',
      <String, Object?>{
        'enabled': enabled,
        'strength': strength.clamp(0, 1000).toInt(),
      },
    );

    return AudioEffectsState.fromMap(result ?? const <Object?, Object?>{});
  }

  Future<bool> startVisualizer() async {
    if (!Platform.isAndroid) {
      return false;
    }

    return await _channel.invokeMethod<bool>('startVisualizer') ?? false;
  }

  Future<List<int>> getVisualizerFrame() async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'getVisualizerFrame',
    );

    if (result?['available'] != true) {
      return const <int>[];
    }

    final waveform = result?['waveform'];

    if (waveform is! List) {
      return const <int>[];
    }

    return waveform
        .whereType<num>()
        .map((value) => value.toInt())
        .toList(growable: false);
  }

  Future<void> stopVisualizer() async {
    await _channel.invokeMethod<void>('stopVisualizer');
  }

  Future<void> release() async {
    await _channel.invokeMethod<void>('release');
  }
}
