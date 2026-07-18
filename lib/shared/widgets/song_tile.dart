import 'package:flutter/material.dart';

import '../../features/music/data/models/song_model.dart';
import '../../features/music/presentation/widgets/song_artwork.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.isFavorite = false,
    this.onFavorite,
    this.trailing,
  });

  final FluteSong song;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SongArtwork(
          id: song.id,
          imageUrl: song.artworkUrl,
          size: 55,
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing ??
          (onFavorite == null
              ? const Icon(Icons.play_arrow)
              : IconButton(
                  tooltip: isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  onPressed: onFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                )),
    );
  }
}
