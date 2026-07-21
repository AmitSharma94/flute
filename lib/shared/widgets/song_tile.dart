import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/music/data/models/song_model.dart';
import '../../features/music/presentation/widgets/song_artwork.dart';
import '../../features/ringtone/data/ringtone_service.dart';
import '../../features/ringtone/presentation/pages/ringtone_crop_page.dart';
import 'add_to_playlist_action.dart';

class SongTile extends ConsumerWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.isFavorite = false,
    this.onFavorite,
    this.trailing,
  });

  final FluteSong song;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: onTap,
      onLongPress: () => _showSongActions(context, ref),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SongArtwork(
          id: song.id,
          size: 55,
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing:
          trailing ??
          (onFavorite == null
              ? IconButton(
                  tooltip: 'More actions',
                  onPressed: () => _showSongActions(context, ref),
                  icon: const Icon(Icons.more_vert_rounded),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      onPressed: onFavorite,
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                    ),
                    IconButton(
                      tooltip: 'More actions',
                      onPressed: () => _showSongActions(context, ref),
                      icon: const Icon(Icons.more_vert_rounded),
                    ),
                  ],
                )),
    );
  }

  Future<void> _showSongActions(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final type = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.content_cut_rounded),
              title: const Text('Create 30s ringtone'),
              subtitle: const Text(
                'Choose and preview a 30-second section',
              ),
              onTap: () => Navigator.pop(
                context,
                'crop_ringtone',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.phone_in_talk_rounded),
              title: const Text('Set full song as ringtone'),
              onTap: () => Navigator.pop(
                context,
                'ringtone',
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.notifications_active_rounded,
              ),
              title: const Text('Set as notification sound'),
              onTap: () => Navigator.pop(
                context,
                'notification',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.alarm_rounded),
              title: const Text('Set as alarm sound'),
              onTap: () => Navigator.pop(
                context,
                'alarm',
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.playlist_add_rounded,
              ),
              title: const Text('Add to playlist'),
              subtitle: const Text(
                'Add this song to a playlist',
              ),
              onTap: () => Navigator.pop(
                context,
                'add_to_playlist',
              ),
            ),
          ],
        ),
      ),
    );

    if (type == null || !context.mounted) {
      return;
    }

    if (type == 'add_to_playlist') {
      await showAddToPlaylistSheet(
        context: context,
        ref: ref,
        song: song,
      );
      return;
    }

    if (type == 'crop_ringtone') {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => RingtoneCropPage(
            song: song,
          ),
        ),
      );
      return;
    }

    final service = RingtoneService();

    if (!await service.canWriteSettings()) {
      if (!context.mounted) {
        return;
      }

      final openSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Allow system setting changes',
          ),
          content: const Text(
            'Android requires permission for Flute to set '
            'ringtones, notification sounds, or alarm sounds.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                false,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                true,
              ),
              child: const Text('Open settings'),
            ),
          ],
        ),
      );

      if (openSettings == true) {
        await service.requestWriteSettings();
      }

      return;
    }

    try {
      final result = await service.setRingtone(
        path: song.path,
        title: song.title,
        type: type,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success
                ? '${song.title} was set successfully.'
                : 'Could not set the selected sound.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not set sound: $error',
          ),
        ),
      );
    }
  }
}