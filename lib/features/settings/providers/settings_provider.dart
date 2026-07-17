import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/settings_service.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool resumePlayback;
  final bool shuffleDefault;
  final bool repeatDefault;
  final bool keepScreenAwake;

  const SettingsState({
    required this.themeMode,
    required this.resumePlayback,
    required this.shuffleDefault,
    required this.repeatDefault,
    required this.keepScreenAwake,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? resumePlayback,
    bool? shuffleDefault,
    bool? repeatDefault,
    bool? keepScreenAwake,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      resumePlayback: resumePlayback ?? this.resumePlayback,
      shuffleDefault: shuffleDefault ?? this.shuffleDefault,
      repeatDefault: repeatDefault ?? this.repeatDefault,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  late final SettingsService _service;

  @override
  Future<SettingsState> build() async {
    _service = SettingsService();

    return SettingsState(
      themeMode: await _service.getThemeMode(),
      resumePlayback: await _service.getResumePlayback(),
      shuffleDefault: await _service.getShuffleDefault(),
      repeatDefault: await _service.getRepeatDefault(),
      keepScreenAwake: await _service.getKeepScreenAwake(),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _service.setThemeMode(mode);

    state = AsyncData(
      state.requireValue.copyWith(
        themeMode: mode,
      ),
    );
  }

  Future<void> setResumePlayback(bool value) async {
    await _service.setResumePlayback(value);

    state = AsyncData(
      state.requireValue.copyWith(
        resumePlayback: value,
      ),
    );
  }

  Future<void> setShuffleDefault(bool value) async {
    await _service.setShuffleDefault(value);

    state = AsyncData(
      state.requireValue.copyWith(
        shuffleDefault: value,
      ),
    );
  }

  Future<void> setRepeatDefault(bool value) async {
    await _service.setRepeatDefault(value);

    state = AsyncData(
      state.requireValue.copyWith(
        repeatDefault: value,
      ),
    );
  }

  Future<void> setKeepScreenAwake(bool value) async {
    await _service.setKeepScreenAwake(value);

    state = AsyncData(
      state.requireValue.copyWith(
        keepScreenAwake: value,
      ),
    );
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);