import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../music/data/models/song_model.dart';

/// Client for the HQ Audio service documented at
/// https://hqaudio.suvojeetsengupta.in/docs/.
///
/// The parser intentionally accepts common snake_case and camelCase response
/// shapes so minor API response revisions do not break the app immediately.
class HqAudioService {
  HqAudioService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = String.fromEnvironment(
    'HQAUDIO_API_BASE_URL',
    defaultValue: 'https://hqaudio.suvojeetsengupta.in',
  );

  static const String _searchPath = String.fromEnvironment(
    'HQAUDIO_SEARCH_PATH',
    defaultValue: '/search',
  );

  final http.Client _client;

  Future<List<FluteSong>> searchSongs(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    Object? lastError;
    final candidates = <String>{
      _searchPath,
      '/api/search',
      '/api/v1/search',
      '/api/search/songs',
    };

    for (final path in candidates) {
      for (final parameterName in const ['q', 'query']) {
        try {
          final uri = _uri(path, {parameterName: trimmed, 'limit': '30'});
          final response = await _client
              .get(uri, headers: const {'Accept': 'application/json'})
              .timeout(const Duration(seconds: 18));

          if (response.statusCode == 404 || response.statusCode == 405) {
            continue;
          }
          if (response.statusCode < 200 || response.statusCode >= 300) {
            lastError = 'HTTP ${response.statusCode}';
            continue;
          }

          final decoded = jsonDecode(response.body);
          final rawResults = _extractList(decoded);
          final songs = rawResults
              .whereType<Map>()
              .map((item) => _toSong(Map<String, dynamic>.from(item)))
              .whereType<FluteSong>()
              .toList(growable: false);

          if (songs.isNotEmpty) return songs;
        } catch (error) {
          lastError = error;
        }
      }
    }

    throw Exception(
      'HQ Audio search returned no playable results${lastError == null ? '' : ': $lastError'}',
    );
  }

  Future<String> resolveStreamUrl(
    FluteSong song, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _isHttpUrl(song.path)) return song.path;

    final providerId = song.path.startsWith('hqaudio://')
        ? song.path.substring('hqaudio://'.length)
        : song.id.replaceFirst('online_', '');

    Object? lastError;
    final paths = [
      '/stream/$providerId',
      '/api/stream/$providerId',
      '/api/v1/stream/$providerId',
      '/song/$providerId',
      '/api/song/$providerId',
      '/api/v1/song/$providerId',
    ];

    for (final path in paths) {
      try {
        final response = await _client
            .get(_uri(path), headers: const {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 18));

        if (response.statusCode == 404 || response.statusCode == 405) {
          continue;
        }
        if (response.statusCode < 200 || response.statusCode >= 300) {
          lastError = 'HTTP ${response.statusCode}';
          continue;
        }

        final contentType = response.headers['content-type'] ?? '';
        if (contentType.startsWith('audio/') ||
            contentType.contains('application/octet-stream')) {
          return response.request?.url.toString() ?? _uri(path).toString();
        }

        final decoded = jsonDecode(response.body);
        final streamUrl = _findUrl(decoded);
        if (streamUrl != null) return streamUrl;
      } catch (error) {
        lastError = error;
      }
    }

    throw Exception(
      'HQ Audio could not resolve a stream${lastError == null ? '' : ': $lastError'}',
    );
  }

  FluteSong? _toSong(Map<String, dynamic> json) {
    final id = _firstText(json, const [
      'id',
      'video_id',
      'videoId',
      'song_id',
      'songId',
      'track_id',
      'trackId',
    ]);
    final title = _firstText(json, const ['title', 'name', 'song']);
    if (id.isEmpty || title.isEmpty) return null;

    final artist = _artistText(json);
    final album = _nestedText(json['album'], const ['name', 'title']);
    final directUrl = _findUrl(json);
    final artwork = _findArtwork(json);
    final durationSeconds = _durationSeconds(json);

    return FluteSong(
      id: 'online_$id',
      title: title,
      artist: artist.isEmpty ? 'Unknown Artist' : artist,
      album: album.isEmpty ? 'Online Music' : album,
      path: directUrl ?? 'hqaudio://$id',
      duration: durationSeconds * 1000,
      source: FluteSongSource.online,
      artworkUrl: artwork,
    );
  }

  List<dynamic> _extractList(dynamic value) {
    if (value is List) return value;
    if (value is! Map) return const [];

    for (final key in const ['results', 'songs', 'tracks', 'items', 'data']) {
      final candidate = value[key];
      if (candidate is List) return candidate;
      if (candidate is Map) {
        final nested = _extractList(candidate);
        if (nested.isNotEmpty) return nested;
      }
    }
    return const [];
  }

  String _artistText(Map<String, dynamic> json) {
    final direct = _firstText(json, const [
      'artist',
      'artist_name',
      'artistName',
      'author',
      'uploader',
      'channel',
    ]);
    if (direct.isNotEmpty) return direct;

    final artists = json['artists'];
    if (artists is List) {
      return artists
          .map(
            (item) => item is Map
                ? _firstText(Map<String, dynamic>.from(item), const ['name'])
                : item.toString(),
          )
          .where((name) => name.trim().isNotEmpty)
          .join(', ');
    }
    if (artists is Map) {
      final primary = artists['primary'];
      if (primary is List) {
        return primary
            .whereType<Map>()
            .map(
              (item) =>
                  _firstText(Map<String, dynamic>.from(item), const ['name']),
            )
            .where((name) => name.isNotEmpty)
            .join(', ');
      }
    }
    return '';
  }

  int _durationSeconds(Map<String, dynamic> json) {
    for (final key in const [
      'duration',
      'duration_seconds',
      'durationSeconds',
      'length',
    ]) {
      final value = json[key];
      if (value is int) return value;
      if (value is double) return value.round();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return 0;
  }

  String? _findArtwork(dynamic value) {
    if (value is Map) {
      for (final key in const [
        'artwork',
        'artwork_url',
        'artworkUrl',
        'thumbnail',
        'thumbnail_url',
        'thumbnailUrl',
        'image',
        'image_url',
        'imageUrl',
        'cover',
      ]) {
        final url = _bestUrl(value[key]);
        if (url != null) return url;
      }
    }
    return null;
  }

  String? _findUrl(dynamic value) {
    if (value is String) return _isHttpUrl(value) ? value : null;
    if (value is List) return _bestUrl(value);
    if (value is! Map) return null;

    for (final key in const [
      'stream_url',
      'streamUrl',
      'audio_url',
      'audioUrl',
      'media_url',
      'mediaUrl',
      'download_url',
      'downloadUrl',
      'playback_url',
      'playbackUrl',
      'url',
      'stream',
      'audio',
      'media',
      'download',
    ]) {
      final url = _bestUrl(value[key]);
      if (url != null) return url;
    }

    for (final entry in value.entries) {
      final key = entry.key.toString().toLowerCase();
      if (key.contains('image') ||
          key.contains('artwork') ||
          key.contains('thumbnail') ||
          key.contains('cover')) {
        continue;
      }
      final nested = entry.value;
      if (nested is Map || nested is List) {
        final url = _findUrl(nested);
        if (url != null) return url;
      }
    }
    return null;
  }

  String? _bestUrl(dynamic value) {
    if (value is String) return _isHttpUrl(value) ? value.trim() : null;
    if (value is Map) return _findUrl(value);
    if (value is! List) return null;

    final entries = value.whereType<Map>().toList();
    for (final quality in const [
      '320kbps',
      '256kbps',
      '160kbps',
      '128kbps',
      '96kbps',
      'high',
      'medium',
      'low',
    ]) {
      for (final entry in entries.reversed) {
        final entryQuality = _firstText(
          Map<String, dynamic>.from(entry),
          const ['quality', 'bitrate'],
        ).toLowerCase();
        if (entryQuality == quality) {
          final url = _findUrl(entry);
          if (url != null) return url;
        }
      }
    }

    for (final entry in entries.reversed) {
      final url = _findUrl(entry);
      if (url != null) return url;
    }

    for (final item in value.reversed) {
      if (item is String && _isHttpUrl(item)) return item;
    }
    return null;
  }

  String _firstText(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isNotEmpty && value != 'null') return value;
    }
    return '';
  }

  String _nestedText(dynamic value, List<String> keys) {
    if (value is String) return value.trim();
    if (value is Map) {
      return _firstText(Map<String, dynamic>.from(value), keys);
    }
    return '';
  }

  bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse(
      '$_baseUrl$normalizedPath',
    ).replace(queryParameters: queryParameters);
  }
}

final hqAudioServiceProvider = Provider<HqAudioService>((ref) {
  return HqAudioService();
});
