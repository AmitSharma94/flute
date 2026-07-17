# Flute — Part 1 Playback Stability

Implemented in this build:

- One shared `AudioPlayer` instance throughout the app.
- Central `PlaybackController` for playback and queue actions.
- Safe play, pause, resume, stop and seek operations.
- Automatic next-song playback after completion.
- Repeat-one behavior on completion.
- Repeat-all queue wrapping.
- Shuffle without immediately selecting the current song again.
- Previous button restarts the song after three seconds; otherwise it moves back.
- Queue index and current-song state update only after a song loads successfully.
- Missing, unsupported and damaged file errors are shown through a SnackBar.
- Rapid player operations are guarded to prevent overlapping load commands.
- Listening history is added through the central controller.
- Clearing history is persisted.
- Invalid stored JSON falls back safely instead of crashing.

## Device test checklist

1. Open Library and play any song.
2. Pause and resume from both the mini player and full player.
3. Seek near the middle and near the end.
4. Let a song finish and verify the next song starts.
5. Test repeat one, repeat all and repeat off.
6. Enable shuffle and press Next several times.
7. After more than three seconds, press Previous and verify the song restarts.
8. Near the beginning, press Previous and verify the previous queue item plays.
9. Delete or move an indexed song, then try playing it and verify an error appears without crashing.
10. Rapidly tap play/next and verify only one load operation runs.

## Environment note

Flutter and Dart SDK executables were not available in the editing environment,
so run `flutter analyze` and the device checklist locally before merging.
