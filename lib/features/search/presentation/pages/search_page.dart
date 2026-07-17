import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../music/providers/music_provider.dart';

import '../../providers/search_provider.dart';

import '../../../player/helpers/play_song.dart';

import '../../../../shared/widgets/song_tile.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);

    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Search")),

      body: songsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text("Error: $e")),

        data: (songs) {
          final results = ref.watch(filteredSongsProvider(songs));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),

                child: TextField(
                  autofocus: true,

                  decoration: InputDecoration(
                    hintText: "Search songs or artists",

                    prefixIcon: const Icon(Icons.search),

                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),

                            onPressed: () {
                              ref.read(searchQueryProvider.notifier).clear();
                            },
                          )
                        : null,

                    border: const OutlineInputBorder(),
                  ),

                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).updateQuery(value);
                  },
                ),
              ),

              Expanded(
                child: results.isEmpty
                    ? const Center(child: Text("No songs found"))
                    : ListView.builder(
                        itemCount: results.length,

                        itemBuilder: (context, index) {
                          final song = results[index];

                          return SongTile(
                            song: song,

                            onTap: () async {
                              await playSong(ref, results, index);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
