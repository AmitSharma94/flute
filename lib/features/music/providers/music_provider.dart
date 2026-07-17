import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/song_model.dart';
import '../data/services/audio_scanner_service.dart';

enum MusicSortMode { title, artist, album, duration }

enum MusicPermissionState { granted, denied }

class MusicLibraryState {
  const MusicLibraryState({
    required this.songs,
    required this.permission,
    required this.sortMode,
  });

  final List<FluteSong> songs;
  final MusicPermissionState permission;
  final MusicSortMode sortMode;

  MusicLibraryState copyWith({
    List<FluteSong>? songs,
    MusicPermissionState? permission,
    MusicSortMode? sortMode,
  }) {
    return MusicLibraryState(
      songs: songs ?? this.songs,
      permission: permission ?? this.permission,
      sortMode: sortMode ?? this.sortMode,
    );
  }
}

final audioScannerProvider = Provider<AudioScannerService>((ref) {
  return AudioScannerService();
});

class MusicLibraryNotifier extends AsyncNotifier<MusicLibraryState> {
  late final AudioScannerService _scanner;

  @override
  Future<MusicLibraryState> build() async {
    _scanner = ref.read(audioScannerProvider);
    return _scan(requestPermission: true, sortMode: MusicSortMode.title);
  }

  Future<MusicLibraryState> _scan({
    required bool requestPermission,
    required MusicSortMode sortMode,
  }) async {
    final allowed = requestPermission
        ? await _scanner.requestPermission()
        : await _scanner.hasPermission();

    if (!allowed) {
      return MusicLibraryState(
        songs: const [],
        permission: MusicPermissionState.denied,
        sortMode: sortMode,
      );
    }

    final songs = await _scanner.getSongs();
    return MusicLibraryState(
      songs: _sortSongs(songs, sortMode),
      permission: MusicPermissionState.granted,
      sortMode: sortMode,
    );
  }

  Future<void> refresh({bool requestPermission = false}) async {
    final sortMode = state.asData?.value.sortMode ?? MusicSortMode.title;
    state = const AsyncLoading<MusicLibraryState>();
    state = await AsyncValue.guard(
      () => _scan(requestPermission: requestPermission, sortMode: sortMode),
    );
  }

  Future<void> setSortMode(MusicSortMode mode) async {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(songs: _sortSongs(current.songs, mode), sortMode: mode),
    );
  }

  Future<bool> openSettings() => _scanner.openSettings();

  List<FluteSong> _sortSongs(List<FluteSong> input, MusicSortMode mode) {
    final songs = [...input];
    int compareText(String a, String b) =>
        a.toLowerCase().compareTo(b.toLowerCase());

    songs.sort((a, b) {
      switch (mode) {
        case MusicSortMode.artist:
          return compareText(a.artist, b.artist);
        case MusicSortMode.album:
          return compareText(a.album, b.album);
        case MusicSortMode.duration:
          return b.duration.compareTo(a.duration);
        case MusicSortMode.title:
          return compareText(a.title, b.title);
      }
    });
    return List.unmodifiable(songs);
  }
}

final musicLibraryProvider =
    AsyncNotifierProvider<MusicLibraryNotifier, MusicLibraryState>(
      MusicLibraryNotifier.new,
    );

final songsProvider = Provider<AsyncValue<List<FluteSong>>>((ref) {
  return ref.watch(musicLibraryProvider).whenData((state) => state.songs);
});
