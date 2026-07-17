# flute_rc_V1 release checklist

## Identity and ownership

- [ ] Launcher label is `flute_rc_V1`.
- [ ] In-app branding shows `flute_rc_V1™`.
- [ ] Version matches `pubspec.yaml`.
- [ ] Copyright and trademark notices are visible in About.
- [ ] `COPYRIGHT` and proprietary `LICENSE` are included.

## Quality

- [ ] `dart format --output=none --set-exit-if-changed lib test`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] Test playback completion, repeat, shuffle, seek, and rapid taps.
- [ ] Test permission denial and permanent denial.
- [ ] Test empty, large, and refreshed libraries.
- [ ] Test session restoration without autoplay.
- [ ] Test Android 12 or earlier and Android 13 or later.

## Android release

- [ ] Create a private upload keystore.
- [ ] Copy `android/key.properties.example` to `android/key.properties`.
- [ ] Never commit keystore or signing passwords.
- [ ] Build `flutter build appbundle --release`.
- [ ] Install and test the release APK on a physical device.
- [ ] Configure GitHub signing secrets before creating a release tag.

## Store preparation

- [ ] Privacy policy is published.
- [ ] App icon and screenshots are final.
- [ ] Store description and support contact are ready.
- [ ] Third-party licenses have been reviewed.
- [ ] Data-safety answers accurately state local audio access.
