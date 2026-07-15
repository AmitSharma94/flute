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



  factory FluteSong.fromJson(
    Map<String, dynamic> json,
  ) {

    return FluteSong(

      id:
          json['id'] ?? '',

      title:
          json['title'] ?? '',

      artist:
          json['artist'] ?? 'Unknown',

      album:
          json['album'] ?? 'Unknown',

      path:
          json['path'] ?? '',

      duration:
          json['duration'] ?? 0,

    );

  }



  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'title': title,

      'artist': artist,

      'album': album,

      'path': path,

      'duration': duration,

    };

  }



  @override
  bool operator ==(
    Object other,
  ) {

    return other is FluteSong &&
        other.id == id;

  }



  @override
  int get hashCode =>
      id.hashCode;

}