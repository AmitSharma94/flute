import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../music/data/models/song_model.dart';

class FavoriteNotifier extends Notifier<List<FluteSong>> {

  @override
  List<FluteSong> build() {
    return [];
  }


  void toggle(FluteSong song) {

    if (state.contains(song)) {
      state = [
        ...state.where(
          (item) => item != song,
        ),
      ];
    } else {
      state = [
        ...state,
        song,
      ];
    }
  }


  bool isFavorite(FluteSong song) {
    return state.contains(song);
  }
}


final favoriteProvider =
    NotifierProvider<
      FavoriteNotifier,
      List<FluteSong>
    >(
      FavoriteNotifier.new,
    );