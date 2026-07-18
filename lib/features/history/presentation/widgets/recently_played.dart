import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/song_tile.dart';
import '../../../player/providers/playback_controller.dart';
import '../../providers/history_provider.dart';

class RecentlyPlayed extends ConsumerWidget {
  const RecentlyPlayed({super.key, this.limit});

  final int? limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final songs = limit == null ? history : history.take(limit!).toList();

    if (songs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(child: Text('Play a song to build your history.')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return SongTile(
          song: song,
          onTap: () => ref
              .read(playbackControllerProvider)
              .setQueueAndPlay(songs, index),
        );
      },
    );
  }
}
