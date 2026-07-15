import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/favorite_provider.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final favorites =
        ref.watch(favoriteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),

      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'No favorites yet',
              ),
            )

          : ListView.builder(
              itemCount: favorites.length,

              itemBuilder: (context, index) {

                final song =
                    favorites[index];

                return ListTile(

                  leading: const Icon(
                    Icons.favorite,
                  ),

                  title: Text(
                    song.title,
                  ),

                  subtitle: Text(
                    song.artist,
                  ),
                );
              },
            ),
    );
  }
}