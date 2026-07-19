# Equalizer and Android Auto additions

## Equalizer

- Added an Android-native equalizer using `android.media.audiofx.Equalizer`.
- The effect attaches to the `just_audio` Android audio-session ID.
- Added Settings > Audio > Equalizer with enable/disable, device presets, and per-band controls.
- The page explains that playback must be started before an audio session exists.
- No Internet access or online audio source was added.

## Android Auto

- Added an Android Auto media declaration (`automotive_app_desc.xml`).
- Exposed an `audio_service` browse tree containing Songs, Albums, and Artists.
- Added local-library search and play-by-media-ID handling.
- Android Auto content is populated from Flute's local scanner only.

## Required testing

Run these on a machine with Flutter installed:

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --release
```

Test the equalizer on a physical Android phone because audio-effect availability varies by manufacturer. Test Android Auto with a real head unit or Google's Desktop Head Unit. The first launch must scan the local library before Android Auto can display media.
