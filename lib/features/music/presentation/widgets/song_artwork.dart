import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongArtwork extends StatelessWidget {
  final String id;
  final double size;
  final String? imageUrl;

  const SongArtwork({
    super.key,
    required this.id,
    this.size = 60,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(Icons.music_note, size: size / 2),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            )
          : QueryArtworkWidget(
              id: int.tryParse(id) ?? 0,
              type: ArtworkType.AUDIO,
              artworkWidth: size,
              artworkHeight: size,
              artworkFit: BoxFit.cover,
              nullArtworkWidget: placeholder,
            ),
    );
  }
}
