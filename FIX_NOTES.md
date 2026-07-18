# flute stability fixes

## Branding and build output
- Visible application name is `flute` on Android, iOS, web, and in-app UI.
- The internal Dart package remains `flute_rc_v1` because Dart package names must be lowercase identifiers.
- GitHub Actions renames release outputs to `flute-release.apk` and `flute-release.aab`.
- Uploaded artifact names are `flute-release-apk` and `flute-release-aab`.

## Playback
- The player no longer awaits the full lifetime of `AudioPlayer.play()`.
- Play, pause, next, previous, seek, shuffle, and repeat commands can run while a track is playing.
- Repeat-one is synchronized with just_audio `LoopMode.one`.
- Online stream URLs are resolved before playback and refreshed once when an expired URL fails.

## Favorites and recently played
- Favorite controls are available from song lists and the player screen.
- Favorites open as a playable queue.
- Recently played records are written immediately after playback starts.
- The home recently-played section and full history page use the persisted history provider.

## Online music
- The online client uses `https://hqaudio.suvojeetsengupta.in` by default.
- Search and stream routes are configurable with Dart defines.
- The parser accepts several common response wrappers, metadata fields, and quality-list formats.

Example override:

```bash
flutter run \
  --dart-define=HQAUDIO_API_BASE_URL=https://hqaudio.suvojeetsengupta.in \
  --dart-define=HQAUDIO_SEARCH_PATH=/search
```

The external service is third-party and may revise endpoint paths or response formats.
