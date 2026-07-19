import 'dart:io';

import '../models/song_model.dart';

class LocalSongDeleteService {
  const LocalSongDeleteService();

  Future<void> delete(FluteSong song) async {
    final path = song.path.trim();
    if (path.isEmpty) {
      throw const FileSystemException('The song has no local file path.');
    }

    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('The audio file no longer exists.', path);
    }

    try {
      await file.delete();
    } on FileSystemException catch (error) {
      throw FileSystemException(
        'Android did not allow Flute to delete this file. '
        'Try deleting it with your Files app.',
        path,
        error.osError,
      );
    }
  }
}
