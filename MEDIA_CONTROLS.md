# Flute media controls

This build adds:

- Android media notification controls
- Android lock-screen controls
- Bluetooth and wired-headset media button handling
- Background playback through `audio_service`
- Android launcher home-screen widget with previous, play/pause, and next

## Add the launcher widget

1. Install and open Flute once.
2. Long-press an empty area of the Android home screen.
3. Choose **Widgets**.
4. Find **flute**.
5. Drag the Flute playback widget to the home screen.

The launcher widget controls the active media session. If Android has killed the
app and no playback session exists, tap the widget body to open Flute first.

## Android 13+

Allow notification permission when requested by Android. Without notification
permission, playback can continue, but the media notification may not be visible.

## Battery behaviour

The audio service remains foregrounded while paused so Android can reliably
resume playback from notification, lock screen, Bluetooth, or the home widget.
