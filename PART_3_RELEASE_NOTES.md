# Part 3 — Release candidate hardening

Completed:

- Renamed the visible app to `flute_rc_V1` and in-app brand to `flute_rc_V1™`.
- Renamed the Dart package to `flute_rc_v1`.
- Set release version to `1.0.0-rc.1+1`.
- Added Amit Sharma trademark and copyright notices.
- Added proprietary `LICENSE` and `COPYRIGHT` files.
- Updated Android and iOS display names and bundle identifiers.
- Added release signing configuration and secret-file exclusions.
- Enabled Android release shrinking and ProGuard configuration.
- Added pull-request and branch CI for format, analysis, tests, and debug build.
- Added tag-triggered APK/AAB release workflow.
- Added a Git CLI branch helper and complete workflow documentation.
- Added a release checklist and refreshed README.

Important:

- The provisional application identifier is `com.amitsharma.flutercv1`.
- Registering a trademark is a legal process; displaying ™ states a trademark
  claim but does not itself create a government registration.
- Before public release, configure a private signing key and GitHub secrets.
- Run Flutter analysis, tests, and physical-device release testing locally.
