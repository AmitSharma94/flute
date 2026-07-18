import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/song_tile.dart';
import '../../../player/providers/playback_controller.dart';
import '../../providers/favorite_provider.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? const Center(
              child: Text('No favorites yet'),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final song = favorites[index];
                return SongTile(
                  song: song,
                  isFavorite: true,
                  onFavorite: () =>
                      ref.read(favoriteProvider.notifier).toggle(song),
                  onTap: () => ref
                      .read(playbackControllerProvider)
                      .setQueueAndPlay(favorites, index),
                );
              },
            ),
    );
  }
}
