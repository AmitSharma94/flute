import 'package:flutter/material.dart';
import '../../features/music/data/models/song_model.dart';

class SongTile extends StatelessWidget {
  final FluteSong song;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 26,
          child: Icon(Icons.music_note),
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
        trailing: const Icon(Icons.more_vert),
        onTap: onTap,
      ),
    );
  }
}