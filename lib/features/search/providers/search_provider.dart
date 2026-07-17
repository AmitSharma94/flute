import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../music/data/models/song_model.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void updateQuery(String value) {
    state = value;
  }

  void clear() {
    state = '';
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final filteredSongsProvider = Provider.family<List<FluteSong>, List<FluteSong>>(
  (ref, songs) {
    final query = ref.watch(searchQueryProvider).toLowerCase();

    if (query.isEmpty) {
      return songs;
    }

    return songs.where((song) {
      return song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query);
    }).toList();
  },
);
