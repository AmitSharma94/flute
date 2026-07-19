import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/music/data/models/song_model.dart';
import '../../features/music/data/services/local_song_delete_service.dart';
import '../../features/music/providers/music_provider.dart';
import '../../features/player/providers/playback_controller.dart';

Future<bool> confirmAndDeleteSong({
  required BuildContext context,
  required WidgetRef ref,
  required FluteSong song,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete song?'),
      content: Text(
        '“${song.title}” will be permanently deleted from this device. '
        'This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) {
    return false;
  }

  final messenger = ScaffoldMessenger.of(context);

  try {
    await const LocalSongDeleteService().delete(song);
    await ref.read(playbackControllerProvider).handleDeletedSong(song);
    await ref.read(musicLibraryProvider.notifier).refresh();

    if (context.mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text('Deleted “${song.title}”.')),
      );
    }
    return true;
  } catch (error) {
    if (context.mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not delete song: $error')),
      );
    }
    return false;
  }
}
