import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../../../history/providers/history_provider.dart';
import '../../../music/providers/music_provider.dart';
import '../../../player/helpers/play_song.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/song_tile.dart';
import '../widgets/cards/music_card.dart';
import '../widgets/greeting_header.dart';
import '../widgets/quick_access_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'flute',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: songsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (songs) => ListView(
          padding: const EdgeInsets.only(bottom: 180),
          children: [
            GreetingHeader(songCount: songs.length),
            QuickAccessSection(
              onFavorites: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              ),
              onRecentlyPlayed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              ),
            ),
            const SectionTitle(title: 'Continue Listening'),
            SizedBox(
              height: 205,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: songs.length > 6 ? 6 : songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: MusicCard(
                      song: song,
                      size: 150,
                      onTap: () => playSong(ref, songs, index),
                    ),
                  );
                },
              ),
            ),
            const SectionTitle(title: 'Recently Played'),
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Text('Your recently played songs will appear here.'),
              )
            else
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: history.length > 5 ? 5 : history.length,
                  itemBuilder: (context, index) {
                    final song = history[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: MusicCard(
                        song: song,
                        size: 125,
                        onTap: () => playSong(ref, history, index),
                      ),
                    );
                  },
                ),
              ),
            const SectionTitle(title: 'All Songs'),
            ...List.generate(
              songs.length,
              (index) => SongTile(
                song: songs[index],
                onTap: () => playSong(ref, songs, index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
