import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../music/data/models/song_model.dart';

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

  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json, audio/*;q=0.9, */*;q=0.8',
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 '
        'Chrome/120.0 Mobile Safari/537.36',
    'Referer': 'https://hqaudio.suvojeetsengupta.in/',
  };

  final http.Client _client;

  Future<List<FluteSong>> searchSongs(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      return const [];
    }

    Object? lastError;

    final candidates = <String>{
      _searchPath,
      if (_searchPath != '/search') '/search',
      '/api/search',
      '/api/v1/search',
      '/api/search/songs',
    };

    for (final path in candidates) {
      for (final parameterName in const ['q', 'query']) {
        try {
          final uri = _uri(
            path,
            {
              parameterName: trimmed,
              'limit': '30',
            },
          );

          final response = await _client
              .get(
                uri,
                headers: _jsonHeaders,
              )
              .timeout(const Duration(seconds: 20));

          if (response.statusCode == 404 || response.statusCode == 405) {
            continue;
          }

          if (response.statusCode < 200 || response.statusCode >= 300) {
            lastError = 'Search HTTP ${response.statusCode}: ${response.body}';
            continue;
          }

          final decoded = jsonDecode(response.body);
          final rawResults = _extractList(decoded);

          final songs = rawResults
              .whereType<Map>()
              .map((item) => _toSong(Map<String, dynamic>.from(item)))
              .whereType<FluteSong>()
              .toList(growable: false);

          if (songs.isNotEmpty) {
            return songs;
          }
        } catch (error) {
          lastError = error;
        }
      }
    }

    throw Exception(
      'HQAudio search returned no results'
      '${lastError == null ? '' : ': $lastError'}',
    );
  }

  Future<String> resolveStreamUrl(
    FluteSong song, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _isHttpUrl(song.path) &&
        _looksLikeAudioUrl(song.path)) {
      return song.path;
    }

    final providerId = song.path.startsWith('hqaudio://')
        ? song.path.substring('hqaudio://'.length)
        : song.id.replaceFirst('online_', '');

    if (providerId.trim().isEmpty) {
      throw Exception('HQAudio song ID is missing.');
    }

    Object? lastError;
    final encodedId = Uri.encodeComponent(providerId);

    final paths = <String>{
      '/stream/$encodedId',
      '/api/stream/$encodedId',
      '/api/v1/stream/$encodedId',
      '/song/$encodedId',
      '/api/song/$encodedId',
      '/api/v1/song/$encodedId',
      '/download/$encodedId',
      '/api/download/$encodedId',
    };

    for (final path in paths) {
      try {
        final uri = _uri(path);

        final request = http.Request('GET', uri)
          ..followRedirects = true
          ..maxRedirects = 8
          ..headers.addAll(_jsonHeaders);

        final streamedResponse = await _client
            .send(request)
            .timeout(const Duration(seconds: 25));

        final finalUri = streamedResponse.request?.url ?? uri;
        final contentType =
            streamedResponse.headers['content-type']?.toLowerCase() ?? '';

        if (streamedResponse.statusCode == 404 ||
            streamedResponse.statusCode == 405) {
          await streamedResponse.stream.drain<void>();
          continue;
        }

        if (streamedResponse.statusCode < 200 ||
            streamedResponse.statusCode >= 300) {
          await streamedResponse.stream.drain<void>();
          lastError = 'Stream HTTP ${streamedResponse.statusCode}';
          continue;
        }

        if (_isAudioContentType(contentType)) {
          await streamedResponse.stream.drain<void>();
          return finalUri.toString();
        }

        final response = await http.Response.fromStream(
          streamedResponse,
        );

        if (response.body.trim().isEmpty) {
          lastError = 'Empty response from $path';
          continue;
        }

        dynamic decoded;

        try {
          decoded = jsonDecode(response.body);
        } on FormatException {
          lastError = 'Expected JSON or audio but received $contentType';
          continue;
        }

        final streamUrl = _findAudioUrl(decoded);

        if (streamUrl != null) {
          return streamUrl;
        }

        lastError = 'No audio URL in response from $path';
      } catch (error) {
        lastError = error;
      }
    }

    throw Exception(
      'HQAudio could not resolve the audio stream'
      '${lastError == null ? '' : ': $lastError'}',
    );
  }

  FluteSong? _toSong(Map<String, dynamic> json) {
    final id = _firstText(
      json,
      const [
        'id',
        'video_id',
        'videoId',
        'song_id',
        'songId',
        'track_id',
        'trackId',
        'token',
      ],
    );

    final title = _firstText(
      json,
      const [
        'title',
        'name',
        'song',
      ],
    );

    if (id.isEmpty || title.isEmpty) {
      return null;
    }

    final artist = _artistText(json);

    final album = _nestedText(
      json['album'],
      const [
        'name',
        'title',
      ],
    );

    final directAudioUrl = _findAudioUrl(json);
    final artwork = _findArtwork(json);
    final durationSeconds = _durationSeconds(json);

    return FluteSong(
      id: 'online_$id',
      title: title,
      artist: artist.isEmpty ? 'Unknown Artist' : artist,
      album: album.isEmpty ? 'Online Music' : album,
      path: directAudioUrl ?? 'hqaudio://$id',
      duration: durationSeconds * 1000,
      source: FluteSongSource.online,
      artworkUrl: artwork,
    );
  }

  List<dynamic> _extractList(dynamic value) {
    if (value is List) {
      return value;
    }

    if (value is! Map) {
      return const [];
    }

    for (final key in const [
      'results',
      'songs',
      'tracks',
      'items',
      'data',
    ]) {
      final candidate = value[key];

      if (candidate is List) {
        return candidate;
      }

      if (candidate is Map) {
        final nested = _extractList(candidate);

        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }

    return const [];
  }

  String _artistText(Map<String, dynamic> json) {
    final direct = _firstText(
      json,
      const [
        'artist',
        'artist_name',
        'artistName',
        'author',
        'uploader',
        'channel',
      ],
    );

    if (direct.isNotEmpty) {
      return direct;
    }

    final artists = json['artists'];

    if (artists is List) {
      return artists
          .map(
            (item) => item is Map
                ? _firstText(
                    Map<String, dynamic>.from(item),
                    const [
                      'name',
                      'title',
                    ],
                  )
                : item.toString(),
          )
          .where((name) => name.trim().isNotEmpty)
          .join(', ');
    }

    if (artists is Map) {
      for (final key in const [
        'primary',
        'all',
        'featured',
      ]) {
        final list = artists[key];

        if (list is List) {
          final names = list
              .whereType<Map>()
              .map(
                (item) => _firstText(
                  Map<String, dynamic>.from(item),
                  const [
                    'name',
                    'title',
                  ],
                ),
              )
              .where((name) => name.isNotEmpty)
              .join(', ');

          if (names.isNotEmpty) {
            return names;
          }
        }
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

      if (value is int) {
        return value;
      }

      if (value is double) {
        return value.round();
      }

      final parsed = int.tryParse(
        value?.toString() ?? '',
      );

      if (parsed != null) {
        return parsed;
      }
    }

    return 0;
  }

  String? _findArtwork(dynamic value) {
    if (value is! Map) {
      return null;
    }

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
      'coverUrl',
    ]) {
      final url = _findAnyHttpUrl(value[key]);

      if (url != null) {
        return url;
      }
    }

    return null;
  }

  String? _findAudioUrl(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      return _looksLikeAudioUrl(value) ? value.trim() : null;
    }

    if (value is List) {
      return _bestAudioUrl(value);
    }

    if (value is! Map) {
      return null;
    }

    for (final key in const [
      'downloadUrl',
      'download_url',
      'streamUrl',
      'stream_url',
      'audioUrl',
      'audio_url',
      'mediaUrl',
      'media_url',
      'playbackUrl',
      'playback_url',
      'download',
      'stream',
      'audio',
      'media',
    ]) {
      final candidate = value[key];
      final url = _audioUrlFromKnownField(candidate);

      if (url != null) {
        return url;
      }
    }

    for (final entry in value.entries) {
      final key = entry.key.toString().toLowerCase();

      if (key.contains('image') ||
          key.contains('artwork') ||
          key.contains('thumbnail') ||
          key.contains('cover') ||
          key == 'url') {
        continue;
      }

      if (entry.value is Map || entry.value is List) {
        final nested = _findAudioUrl(entry.value);

        if (nested != null) {
          return nested;
        }
      }
    }

    return null;
  }

  String? _audioUrlFromKnownField(dynamic value) {
    if (value is String) {
      return _isHttpUrl(value) ? value.trim() : null;
    }

    if (value is List) {
      return _bestAudioUrl(value);
    }

    if (value is Map) {
      for (final key in const [
        'url',
        'link',
        'src',
        'value',
      ]) {
        final candidate = value[key];

        if (candidate is String && _isHttpUrl(candidate)) {
          return candidate.trim();
        }
      }

      return _findAudioUrl(value);
    }

    return null;
  }

  String? _bestAudioUrl(dynamic value) {
    if (value is String) {
      return _isHttpUrl(value) ? value.trim() : null;
    }

    if (value is Map) {
      return _audioUrlFromKnownField(value);
    }

    if (value is! List) {
      return null;
    }

    final entries = value
        .whereType<Map>()
        .map(Map<String, dynamic>.from)
        .toList(growable: false);

    for (final quality in const [
      '320kbps',
      '320',
      '256kbps',
      '256',
      '160kbps',
      '160',
      '128kbps',
      '128',
      '96kbps',
      '96',
      'high',
      'medium',
      'low',
    ]) {
      for (final entry in entries.reversed) {
        final entryQuality = _firstText(
          entry,
          const [
            'quality',
            'bitrate',
            'label',
          ],
        ).toLowerCase();

        if (entryQuality == quality) {
          final url = _audioUrlFromKnownField(entry);

          if (url != null) {
            return url;
          }
        }
      }
    }

    for (final entry in entries.reversed) {
      final url = _audioUrlFromKnownField(entry);

      if (url != null) {
        return url;
      }
    }

    for (final item in value.reversed) {
      if (item is String && _isHttpUrl(item)) {
        return item.trim();
      }
    }

    return null;
  }

  String? _findAnyHttpUrl(dynamic value) {
    if (value is String) {
      return _isHttpUrl(value) ? value.trim() : null;
    }

    if (value is List) {
      for (final item in value.reversed) {
        final url = _findAnyHttpUrl(item);

        if (url != null) {
          return url;
        }
      }

      return null;
    }

    if (value is Map) {
      for (final key in const [
        'url',
        'link',
        'src',
        'value',
      ]) {
        final url = _findAnyHttpUrl(value[key]);

        if (url != null) {
          return url;
        }
      }
    }

    return null;
  }

  String _firstText(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key]?.toString().trim() ?? '';

      if (value.isNotEmpty && value != 'null') {
        return value;
      }
    }

    return '';
  }

  String _nestedText(
    dynamic value,
    List<String> keys,
  ) {
    if (value is String) {
      return value.trim();
    }

    if (value is Map) {
      return _firstText(
        Map<String, dynamic>.from(value),
        keys,
      );
    }

    return '';
  }

  bool _isAudioContentType(String contentType) {
    return contentType.startsWith('audio/') ||
        contentType.contains('application/octet-stream') ||
        contentType.contains('application/vnd.apple.mpegurl') ||
        contentType.contains('application/x-mpegurl');
  }

  bool _looksLikeAudioUrl(String value) {
    final trimmed = value.trim();

    if (!_isHttpUrl(trimmed)) {
      return false;
    }

    final lower = trimmed.toLowerCase();

    return lower.contains('.mp3') ||
        lower.contains('.m4a') ||
        lower.contains('.aac') ||
        lower.contains('.ogg') ||
        lower.contains('.opus') ||
        lower.contains('.flac') ||
        lower.contains('.wav') ||
        lower.contains('.m3u8') ||
        lower.contains('audio') ||
        lower.contains('stream') ||
        lower.contains('download');
  }

  bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value.trim());

    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Uri _uri(
    String path, [
    Map<String, String>? queryParameters,
  ]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse(
      '$_baseUrl$normalizedPath',
    ).replace(
      queryParameters: queryParameters,
    );
  }

  void dispose() {
    _client.close();
  }
}

final hqAudioServiceProvider = Provider<HqAudioService>((ref) {
  final service = HqAudioService();

  ref.onDispose(service.dispose);

  return service;
});
