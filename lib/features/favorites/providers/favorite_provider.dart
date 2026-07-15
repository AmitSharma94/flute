import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_service.dart';
import '../../music/data/models/song_model.dart';


class FavoriteNotifier extends Notifier<List<FluteSong>> {


  @override
  List<FluteSong> build() {

    _loadFavorites();

    return [];

  }



  Future<void> _loadFavorites() async {

    final data =
        await StorageService.load(
          StorageService.favoritesKey,
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



  Future<void> toggle(
    FluteSong song,
  ) async {


    if (state.contains(song)) {

      state =
          state
              .where(
                (item) => item != song,
              )
              .toList();

    } else {

      state = [
        ...state,
        song,
      ];

    }


    await StorageService.save(

      StorageService.favoritesKey,


      state
          .map(
            (song) =>
                song.toJson(),
          )
          .toList(),

    );

  }

}



final favoriteProvider =
    NotifierProvider<
        FavoriteNotifier,
        List<FluteSong>
    >(
      FavoriteNotifier.new,
    );