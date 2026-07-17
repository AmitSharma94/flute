import 'package:flutter/material.dart';

import '../../../../music/data/models/song_model.dart';
import '../../../../music/presentation/widgets/song_artwork.dart';

class MusicCard extends StatelessWidget {
  final FluteSong song;

  final double size;

  const MusicCard({super.key, required this.song, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),

            child: SongArtwork(
              id: song.id,
              imageUrl: song.artworkUrl,

              size: size,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            song.title,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          Text(
            song.artist,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
