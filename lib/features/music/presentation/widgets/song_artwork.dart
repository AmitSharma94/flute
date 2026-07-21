import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongArtwork extends StatelessWidget {
  final String id;
  final double size;
  final double borderRadius;

  const SongArtwork({
    super.key,
    required this.id,
    this.size = 60,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final placeholder = Container(
      width: size,
      height: size,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.music_note_rounded,
        size: size * 0.45,
        color: colorScheme.onSurfaceVariant,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: QueryArtworkWidget(
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