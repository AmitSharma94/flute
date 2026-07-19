class FluteSong {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String path;
  final int duration;

  const FluteSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.duration,
  });

  FluteSong copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? path,
    int? duration,
  }) {
    return FluteSong(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      path: path ?? this.path,
      duration: duration ?? this.duration,
    );
  }

  factory FluteSong.fromJson(Map<String, dynamic> json) {
    return FluteSong(
      id: json['id']?.toString() ?? '',
      title: _text(json['title'], 'Unknown Title'),
      artist: _text(json['artist'], 'Unknown Artist'),
      album: _text(json['album'], 'Unknown Album'),
      path: json['path']?.toString() ?? '',
      duration: _integer(json['duration']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'path': path,
    'duration': duration,
  };

  static String _text(dynamic value, String fallback) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static int _integer(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  bool operator ==(Object other) => other is FluteSong && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
