import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String favoritesKey = 'favorites';
  static const String historyKey = 'history';
  static const String playbackSessionKey = 'playback_session_v1';

  static Future<void> save(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  static Future<List<dynamic>> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    if (value == null || value.isEmpty) return [];

    try {
      final decoded = jsonDecode(value);
      return decoded is List ? decoded : [];
    } catch (_) {
      await prefs.remove(key);
      return [];
    }
  }

  static Future<void> saveObject(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> loadObject(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    if (value == null || value.isEmpty) return null;

    try {
      final decoded = jsonDecode(value);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // Invalid data is removed below.
    }
    await prefs.remove(key);
    return null;
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
