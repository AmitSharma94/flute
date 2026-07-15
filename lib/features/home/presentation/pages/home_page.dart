import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../music/providers/music_provider.dart';
import '../../../player/providers/player_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(songsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flute"),
        centerTitle: true,
      ),
      body: songs.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text("Error: $e"),
        ),
        data: (songs) {
          if (songs.isEmpty) {
            return const Center(
              child: Text(
                "No songs found.\nGrant media permission and add music to your device.",
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];

              return ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(song.title),
                subtitle: Text(song.artist),
                trailing: const Icon(Icons.play_arrow),
                onTap: () async {
                  final player = ref.read(audioPlayerProvider);

                  try {
                    await player.play(song.path);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to play: $e"),
                        ),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}