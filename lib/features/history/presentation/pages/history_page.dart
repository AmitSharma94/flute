import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/song_tile.dart';
import '../../../player/providers/playback_controller.dart';
import '../../providers/history_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Played'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              onPressed: () =>
                  ref.read(historyProvider.notifier).clearHistory(),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('No recently played songs'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final song = history[index];
                return SongTile(
                  song: song,
                  onTap: () => ref
                      .read(playbackControllerProvider)
                      .setQueueAndPlay(history, index),
                );
              },
            ),
    );
  }
}
