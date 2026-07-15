import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_service.dart';
import '../../music/data/models/song_model.dart';


class HistoryNotifier extends Notifier<List<FluteSong>> {


  @override
  List<FluteSong> build() {

    _loadHistory();

    return [];

  }



  Future<void> _loadHistory() async {

    final data =
        await StorageService.load(
          StorageService.historyKey,
        );


    final songs =
        data
            .map(
              (item) =>
                  FluteSong.fromJson(item),
            )
            .toList();


    state = songs;

  }




  Future<void> addSong(
    FluteSong song,
  ) async {


    state = [

      song,

      ...state.where(
        (item) => item != song,
      ),

    ];



    if (state.length > 20) {

      state =
          state.sublist(
            0,
            20,
          );

    }



    await StorageService.save(

      StorageService.historyKey,


      state
          .map(
            (song) =>
                song.toJson(),
          )
          .toList(),

    );

  }



  void clearHistory() {

    state = [];

  }

}




final historyProvider =
    NotifierProvider<
        HistoryNotifier,
        List<FluteSong>
    >(
      HistoryNotifier.new,
    );