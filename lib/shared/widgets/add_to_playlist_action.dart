import '../../features/music/data/models/playlist_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/music/data/models/song_model.dart';
import '../../features/music/providers/playlist_provider.dart';

Future<bool> showAddToPlaylistSheet({
  required BuildContext context,
  required WidgetRef ref,
  required FluteSong song,
}) async {
  final playlists = ref.read(playlistProvider);

  final result = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Add to playlist',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (playlists.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No playlists yet.\nCreate one to add this song.',
                    textAlign: TextAlign.center,
                  ),
                ),

              ...playlists.map(
                (playlist) => ListTile(
                  leading: const Icon(Icons.playlist_play_rounded),
                  title: Text(playlist.name),
                  subtitle: Text(
                    '${playlist.songs.length} song'
                    '${playlist.songs.length == 1 ? '' : 's'}',
                  ),
                  onTap: () async {
                    await ref
                        .read(playlistProvider.notifier)
                        .addSong(playlist.id, song);

                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext, true);
                    }
                  },
                ),
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.add_rounded),
                title: const Text('Create new playlist'),
                onTap: () async {
                  Navigator.pop(sheetContext);

                  final created =
                      await showCreatePlaylistDialog(
                    context: context,
                    ref: ref,
                  );

                  if (created == null || !context.mounted) {
                    return;
                  }

                  await ref
                      .read(playlistProvider.notifier)
                      .addSong(created.id, song);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added to “${created.name}”.',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );

  return result == true;
}

Future<FlutePlaylist?> showCreatePlaylistDialog({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final controller = TextEditingController();

  final name = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Create playlist'),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Playlist name',
          hintText: 'e.g. Workout',
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.pop(dialogContext, value.trim());
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final value = controller.text.trim();

            if (value.isNotEmpty) {
              Navigator.pop(dialogContext, value);
            }
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );

  controller.dispose();

  if (name == null || name.trim().isEmpty) {
    return null;
  }

  return ref
      .read(playlistProvider.notifier)
      .createPlaylist(name.trim());
}