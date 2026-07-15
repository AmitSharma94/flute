import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../music/data/models/song_model.dart';


class HistoryNotifier extends Notifier<List<FluteSong>> {

  @override
  List<FluteSong> build() {
    return [];
  }


  void addSong(FluteSong song) {

    state = [
      song,
      ...state.where(
        (item) => item != song,
      ),
    ];

    if (state.length > 20) {
      state = state.sublist(0,20);
    }
  }
}


final historyProvider =
    NotifierProvider<
        HistoryNotifier,
        List<FluteSong>
    >(
      HistoryNotifier.new,
    );