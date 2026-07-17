# Flute Part 2 — Library, storage, and reliability

## Implemented

- Recoverable music permission state with Retry and Open app settings actions.
- Android 12-and-earlier storage permission declaration.
- Pull-to-refresh and toolbar refresh for the local music library.
- Sorting by title, artist, album, and duration.
- Better unknown title/artist/album normalization.
- Empty-library and scan-error states.
- Defensive JSON decoding for lists and objects.
- Safer favorites/history loading that preserves early user actions.
- Cleanup of favorites/history records for files no longer in the scanned library.
- Playback session persistence: queue, selected index, and playback position.
- Previous session restoration in a paused state when Resume playback is enabled.
- Session position checkpointing approximately every five seconds.

## Device test checklist

1. Fresh install: deny permission, retry, and open system settings.
2. Grant permission on Android 12 or earlier and Android 13 or later.
3. Pull down to refresh after adding or deleting a music file.
4. Test all four library sort modes.
5. Favorite and play songs, close the app, and relaunch it.
6. Confirm the previous song and position return without unexpected autoplay.
7. Disable Resume playback, close and relaunch, and confirm no session is restored.
8. Delete a favorited/recent song, refresh, and confirm stale records are removed.
9. Corrupt a SharedPreferences JSON value during development and confirm the app recovers.

## Commands

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run
```

Flutter/Dart were unavailable in the editing environment, so analyzer and physical-device checks remain required.
