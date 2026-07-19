# Offline release and CI fixes

## Build failures addressed

- Both workflows now restore the missing Android Gradle wrapper before building.
- CI builds from the Flutter project root with `flutter build apk --release` instead of invoking Gradle from `android/` directly.
- The release workflow no longer fails only because committed Dart files need formatting; it formats them before analysis.
- The duplicate `com.example.flute.MainActivity` source was removed so Android has one unambiguous launcher activity.

## Online functionality removed

- Removed the Online tab and its HQ Audio service/page.
- Removed the `http` and `google_fonts` direct dependencies.
- Removed remote stream resolution and HTTP audio playback.
- Removed network artwork loading.
- Removed Android Internet permissions from main, debug, and profile manifests.
- Stored online favorites/history entries are ignored during migration.
- Playback now rejects HTTP/HTTPS sources and only opens files that exist locally.

## Validation

Run the same checks used by GitHub Actions:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```
