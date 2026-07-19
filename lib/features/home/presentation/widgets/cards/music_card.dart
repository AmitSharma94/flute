import 'package:flutter/material.dart';

import '../../../../music/data/models/song_model.dart';
import '../../../../music/presentation/widgets/song_artwork.dart';

class MusicCard extends StatelessWidget {
  const MusicCard({
    super.key,
    required this.song,
    required this.onTap,
    this.size = 150,
  });

  final FluteSong song;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SongArtwork(
                id: song.id,
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
      ),
    );
  }
}
