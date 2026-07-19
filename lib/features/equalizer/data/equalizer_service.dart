import 'dart:io';

import 'package:flutter/services.dart';

class EqualizerBand {
  const EqualizerBand({
    required this.index,
    required this.centerFrequencyHz,
    required this.level,
  });

  final int index;
  final int centerFrequencyHz;
  final int level;
}

class EqualizerState {
  const EqualizerState({
    required this.supported,
    required this.enabled,
    required this.minLevel,
    required this.maxLevel,
    required this.bands,
    required this.presets,
    required this.currentPreset,
  });

  const EqualizerState.unsupported()
    : supported = false,
      enabled = false,
      minLevel = -1500,
      maxLevel = 1500,
      bands = const [],
      presets = const [],
      currentPreset = -1;

  final bool supported;
  final bool enabled;
  final int minLevel;
  final int maxLevel;
  final List<EqualizerBand> bands;
  final List<String> presets;
  final int currentPreset;

  factory EqualizerState.fromMap(Map<Object?, Object?> map) {
    final rawBands = (map['bands'] as List<Object?>? ?? const []);
    return EqualizerState(
      supported: map['supported'] as bool? ?? false,
      enabled: map['enabled'] as bool? ?? false,
      minLevel: map['minLevel'] as int? ?? -1500,
      maxLevel: map['maxLevel'] as int? ?? 1500,
      bands: rawBands.map((entry) {
        final band = Map<Object?, Object?>.from(entry! as Map);
        return EqualizerBand(
          index: band['index'] as int,
          centerFrequencyHz: band['centerFrequencyHz'] as int,
          level: band['level'] as int,
        );
      }).toList(growable: false),
      presets: (map['presets'] as List<Object?>? ?? const [])
          .map((value) => value.toString())
          .toList(growable: false),
      currentPreset: map['currentPreset'] as int? ?? -1,
    );
  }
}

class EqualizerService {
  static const MethodChannel _channel = MethodChannel(
    'com.amitsharma.flute/equalizer',
  );

  Future<EqualizerState> attach(int? audioSessionId) async {
    if (!Platform.isAndroid || audioSessionId == null || audioSessionId <= 0) {
      return const EqualizerState.unsupported();
    }
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'attach',
      <String, Object?>{'audioSessionId': audioSessionId},
    );
    return EqualizerState.fromMap(result ?? const {});
  }

  Future<EqualizerState> getState() async {
    if (!Platform.isAndroid) return const EqualizerState.unsupported();
    final result = await _channel.invokeMapMethod<Object?, Object?>('getState');
    return EqualizerState.fromMap(result ?? const {});
  }

  Future<EqualizerState> setEnabled(bool enabled) async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'setEnabled',
      <String, Object?>{'enabled': enabled},
    );
    return EqualizerState.fromMap(result ?? const {});
  }

  Future<EqualizerState> setBandLevel(int band, int level) async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'setBandLevel',
      <String, Object?>{'band': band, 'level': level},
    );
    return EqualizerState.fromMap(result ?? const {});
  }

  Future<EqualizerState> usePreset(int preset) async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'usePreset',
      <String, Object?>{'preset': preset},
    );
    return EqualizerState.fromMap(result ?? const {});
  }

  Future<void> release() async {
    if (Platform.isAndroid) await _channel.invokeMethod<void>('release');
  }
}
