import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../music/data/models/song_model.dart';

class JioSaavnService {
  JioSaavnService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = String.fromEnvironment(
    'JIOSAAVN_API_BASE_URL',
    defaultValue: 'https://saavn.sumit.co',
  );

  final http.Client _client;

  Future<List<FluteSong>> searchSongs(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final uri = Uri.parse('$_baseUrl/api/search/songs').replace(
      queryParameters: {'query': trimmed, 'page': '1', 'limit': '30'},
    );
    final response = await _client.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Online search failed (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected JioSaavn response.');
    }

    final data = decoded['data'];
    final rawResults = data is Map<String, dynamic> ? data['results'] : null;
    if (rawResults is! List) return const [];

    return rawResults
        .whereType<Map>()
        .map((item) => _toSong(Map<String, dynamic>.from(item)))
        .whereType<FluteSong>()
        .toList(growable: false);
  }

  FluteSong? _toSong(Map<String, dynamic> json) {
    final id = _string(json['id']);
    final title = _string(json['name']).isNotEmpty
        ? _string(json['name'])
        : _string(json['title']);
    final streamUrl = _bestUrl(json['downloadUrl']);
    if (id.isEmpty || title.isEmpty || streamUrl == null) return null;

    final artists = json['artists'];
    final primaryArtists = artists is Map ? artists['primary'] : null;
    final artist = primaryArtists is List
        ? primaryArtists
            .whereType<Map>()
            .map((e) => _string(e['name']))
            .where((e) => e.isNotEmpty)
            .join(', ')
        : '';

    final albumData = json['album'];
    final album = albumData is Map ? _string(albumData['name']) : '';

    return FluteSong(
      id: 'online_$id',
      title: title,
      artist: artist.isEmpty ? 'Unknown Artist' : artist,
      album: album.isEmpty ? 'Unknown Album' : album,
      path: streamUrl,
      duration: _int(json['duration']) * 1000,
      source: FluteSongSource.online,
      artworkUrl: _bestUrl(json['image']),
    );
  }

  String? _bestUrl(dynamic value) {
    if (value is String && value.startsWith('http')) return value;
    if (value is! List) return null;
    final entries = value.whereType<Map>().toList();
    for (final preferred in ['160kbps', '96kbps', '320kbps', '48kbps', '12kbps']) {
      for (final entry in entries.reversed) {
        if (_string(entry['quality']).toLowerCase() == preferred.toLowerCase()) {
          final url = _string(entry['url']);
          if (url.startsWith('http')) return url;
        }
      }
    }
    for (final entry in entries.reversed) {
      final url = _string(entry['url']);
      if (url.startsWith('http')) return url;
    }
    return null;
  }

  String _string(dynamic value) => value?.toString().trim() ?? '';
  int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
}
