# Flute next-release audio features

Added:

- Set a local song as ringtone, notification sound, or alarm sound.
- Android native live waveform visualizer.
- Loudness boost limited to +6 dB.
- Generic `Flute Spatial` headphone effect.
- Existing equalizer and Android Auto support remain intact.

## Android permissions

- `WRITE_SETTINGS` is used only after the user chooses to set a system sound.
- `RECORD_AUDIO` is required by Android's `Visualizer` API. Flute does not record or store microphone audio.

## Device limitations

Audio effects vary by manufacturer. Loudness, spatial processing, equalizer, and visualization may be unavailable on some devices or audio routes.

Dolby and SRS are proprietary and are not bundled or advertised by Flute.
