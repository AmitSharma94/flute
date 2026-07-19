# 30-second ringtone cropper

Flute now includes a song action named **Create 30s ringtone**.

The user can:

- choose the start point of a fixed 30-second section;
- preview that exact section;
- export it as an M4A file without modifying the original song;
- set the generated clip as the Android ringtone.

The implementation uses `native_audio_trimmer` and stores generated clips in the app documents directory before copying the chosen clip into Android MediaStore.

Run:

```text
flutter clean
flutter pub get
dart format lib
flutter analyze
flutter test
flutter build apk --release
```

Test with MP3, M4A, WAV, OGG, and FLAC files on a physical Android device.
