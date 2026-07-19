# Delete local songs

Flute now provides **Delete from device** in:

- The song tile long-press / overflow menu
- The full Now Playing page overflow menu

Before deletion, Flute shows a permanent-delete confirmation. After a successful deletion it removes the track from the playback queue, updates the current track safely, refreshes the scanned library, and lets the existing library cleanup remove stale favorites/history entries.

Android storage providers may refuse direct deletion for some protected locations. In that case Flute shows an error and leaves the library entry untouched until the file is removed through the system Files app.
