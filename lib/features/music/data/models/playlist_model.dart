import 'song_model.dart';

class FlutePlaylist {
  final String id;
  final String name;
  final List<FluteSong> songs;
  final DateTime createdAt;

  const FlutePlaylist({
    required this.id,
    required this.name,
    required this.songs,
    required this.createdAt,
  });

  FlutePlaylist copyWith({
    String? id,
    String? name,
    List<FluteSong>? songs,
    DateTime? createdAt,
  }) {
    return FlutePlaylist(
      id: id ?? this.id,
      name: name ?? this.name,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory FlutePlaylist.fromJson(Map<String, dynamic> json) {
    final songsData = json['songs'];

    return FlutePlaylist(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Playlist',
      songs: songsData is List
          ? songsData
              .whereType<Map>()
              .map(
                (song) => FluteSong.fromJson(
                  Map<String, dynamic>.from(song),
                ),
              )
              .toList()
          : const [],
      createdAt: DateTime.tryParse(
            json['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songs': songs.map((song) => song.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}