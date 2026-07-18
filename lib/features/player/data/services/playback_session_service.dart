import '../../../music/data/models/song_model.dart';
import '../../../../core/storage/storage_service.dart';

class PlaybackSession {
  const PlaybackSession({
    required this.queue,
    required this.index,
    required this.position,
  });

  final List<FluteSong> queue;
  final int index;
  final Duration position;

  Map<String, dynamic> toJson() => {
        'queue': queue.map((song) => song.toJson()).toList(),
        'index': index,
        'positionMs': position.inMilliseconds,
      };

  factory PlaybackSession.fromJson(Map<String, dynamic> json) {
    final rawQueue = json['queue'];
    final queue = rawQueue is List
        ? rawQueue
            .whereType<Map>()
            .map((item) => FluteSong.fromJson(Map<String, dynamic>.from(item)))
            .where((song) => song.id.isNotEmpty && song.path.isNotEmpty)
            .toList()
        : <FluteSong>[];

    final rawIndex = json['index'];
    final index = rawIndex is int
        ? rawIndex
        : int.tryParse(rawIndex?.toString() ?? '') ?? 0;
    final rawPosition = json['positionMs'];
    final positionMs = rawPosition is int
        ? rawPosition
        : int.tryParse(rawPosition?.toString() ?? '') ?? 0;

    return PlaybackSession(
      queue: queue,
      index: index,
      position: Duration(milliseconds: positionMs.clamp(0, 86400000).toInt()),
    );
  }
}

class PlaybackSessionService {
  Future<void> save(PlaybackSession session) => StorageService.saveObject(
        StorageService.playbackSessionKey,
        session.toJson(),
      );

  Future<PlaybackSession?> load() async {
    final data =
        await StorageService.loadObject(StorageService.playbackSessionKey);
    if (data == null) return null;
    final session = PlaybackSession.fromJson(data);
    return session.queue.isEmpty ? null : session;
  }

  Future<void> clear() =>
      StorageService.remove(StorageService.playbackSessionKey);
}
