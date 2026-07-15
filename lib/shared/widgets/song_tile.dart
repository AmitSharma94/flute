import 'package:flutter/material.dart';

import '../../features/music/data/models/song_model.dart';
import '../../features/music/presentation/widgets/song_artwork.dart';


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

    return ListTile(

      onTap: onTap,


      leading: SongArtwork(

        id: song.id,

        size: 55,

      ),


      title: Text(

        song.title,

        maxLines: 1,

        overflow:
            TextOverflow.ellipsis,

      ),


      subtitle: Text(

        song.artist,

        maxLines: 1,

        overflow:
            TextOverflow.ellipsis,

      ),


      trailing:
          const Icon(
            Icons.play_arrow,
          ),

    );

  }

}