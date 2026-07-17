# flute_rc_V1™

A private offline music player built with Flutter.

**Release:** `1.0.0-rc.1`  
**Owner:** Amit Sharma  
**Copyright:** © 2026 Amit Sharma. All rights reserved.  
**Trademark:** flute_rc_V1™ is a trademark of Amit Sharma.

## Current functionality

- Local audio-library scanning and refresh
- Unified playback engine
- Play, pause, seek, next, and previous
- Automatic queue progression
- Shuffle and repeat modes
- Favorites and listening history
- Session and position restoration without automatic playback
- Theme and playback settings
- Android permission recovery

## Development checks

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

## Git CLI workflow

See [`docs/GIT_CLI_FLOW.md`](docs/GIT_CLI_FLOW.md), or run:

```bash
./scripts/git-flow.sh
```

## Release build

```bash
flutter build apk --release
flutter build appbundle --release
```

Android signing instructions are described in `RELEASE_CHECKLIST.md` and
`android/key.properties.example`.

## Legal

This repository is proprietary. See `LICENSE` and `COPYRIGHT`. Third-party
packages retain their own licenses.
