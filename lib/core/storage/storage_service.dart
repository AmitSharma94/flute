import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


class StorageService {


  static const String favoritesKey =
      'favorites';



  static const String historyKey =
      'history';



  static Future<void> save(
    String key,
    List<Map<String,dynamic>> data,
  ) async {

    final prefs =
        await SharedPreferences.getInstance();


    await prefs.setString(
      key,
      jsonEncode(data),
    );

  }



  static Future<List<dynamic>> load(
    String key,
  ) async {

    final prefs =
        await SharedPreferences.getInstance();


    final value =
        prefs.getString(key);



    if (value == null) {
      return [];
    }


    return jsonDecode(value);

  }

}