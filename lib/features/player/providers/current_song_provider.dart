import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../music/data/models/song_model.dart';


class CurrentSongNotifier extends Notifier<FluteSong?> {

  @override
  FluteSong? build() {
    return null;
  }


  void setSong(FluteSong song) {
    state = song;
  }

}


final currentSongProvider =
    NotifierProvider<CurrentSongNotifier, FluteSong?>(
  CurrentSongNotifier.new,
);