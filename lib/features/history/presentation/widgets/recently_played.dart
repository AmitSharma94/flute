import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/history_provider.dart';

class RecentlyPlayed extends ConsumerWidget {
  const RecentlyPlayed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Padding(
          padding: EdgeInsets.all(16),

          child: Text(
            'Recently Played',

            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        SizedBox(
          height: 120,

          child: ListView.builder(
            scrollDirection: Axis.horizontal,

            itemCount: history.length,

            itemBuilder: (context, index) {
              final song = history[index];

              return Card(
                child: Container(
                  width: 150,

                  padding: const EdgeInsets.all(12),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Icon(Icons.music_note, size: 40),

                      Text(
                        song.title,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,
                      ),

                      Text(
                        song.artist,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
