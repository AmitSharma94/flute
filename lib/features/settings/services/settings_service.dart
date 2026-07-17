import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _themeModeKey = 'theme_mode';
  static const _resumePlaybackKey = 'resume_playback';
  static const _shuffleDefaultKey = 'shuffle_default';
  static const _repeatDefaultKey = 'repeat_default';
  static const _keepScreenAwakeKey = 'keep_screen_awake';

  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  // Theme

  Future<ThemeMode> getThemeMode() async {
    final prefs = await _prefs;

    final value =
        prefs.getString(_themeModeKey) ?? 'dark';

    switch (value) {
      case 'light':
        return ThemeMode.light;

      case 'system':
        return ThemeMode.system;

      default:
        return ThemeMode.dark;
    }
  }

  Future<void> setThemeMode(
    ThemeMode mode,
  ) async {
    final prefs = await _prefs;

    String value = 'dark';

    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;

      case ThemeMode.system:
        value = 'system';
        break;

      case ThemeMode.dark:
        value = 'dark';
        break;
    }

    await prefs.setString(
      _themeModeKey,
      value,
    );
  }

  // Resume Playback

  Future<bool> getResumePlayback() async {
    final prefs = await _prefs;

    return prefs.getBool(
          _resumePlaybackKey,
        ) ??
        true;
  }

  Future<void> setResumePlayback(
    bool value,
  ) async {
    final prefs = await _prefs;

    await prefs.setBool(
      _resumePlaybackKey,
      value,
    );
  }

  // Shuffle

  Future<bool> getShuffleDefault() async {
    final prefs = await _prefs;

    return prefs.getBool(
          _shuffleDefaultKey,
        ) ??
        false;
  }

  Future<void> setShuffleDefault(
    bool value,
  ) async {
    final prefs = await _prefs;

    await prefs.setBool(
      _shuffleDefaultKey,
      value,
    );
  }

  // Repeat

  Future<bool> getRepeatDefault() async {
    final prefs = await _prefs;

    return prefs.getBool(
          _repeatDefaultKey,
        ) ??
        false;
  }

  Future<void> setRepeatDefault(
    bool value,
  ) async {
    final prefs = await _prefs;

    await prefs.setBool(
      _repeatDefaultKey,
      value,
    );
  }

  // Keep Screen Awake

  Future<bool> getKeepScreenAwake() async {
    final prefs = await _prefs;

    return prefs.getBool(
          _keepScreenAwakeKey,
        ) ??
        false;
  }

  Future<void> setKeepScreenAwake(
    bool value,
  ) async {
    final prefs = await _prefs;

    await prefs.setBool(
      _keepScreenAwakeKey,
      value,
    );
  }
}