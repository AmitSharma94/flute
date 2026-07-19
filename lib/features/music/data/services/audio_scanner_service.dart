import 'dart:io';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioScannerService {
  AudioScannerService({
    OnAudioQuery? audioQuery,
  }) : _audioQuery = audioQuery ?? OnAudioQuery();

  final OnAudioQuery _audioQuery;

  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    // on_audio_query handles READ_MEDIA_AUDIO on Android 13+
    // and READ_EXTERNAL_STORAGE on older Android versions.
    final granted = await _audioQuery.permissionsRequest();

    if (granted) {
      return true;
    }

    // Fallback through permission_handler.
    final audioStatus = await Permission.audio.request();

    if (audioStatus.isGranted) {
      return true;
    }

    final storageStatus = await Permission.storage.request();

    if (storageStatus.isGranted) {
      return true;
    }

    return false;
  }

  Future<bool> hasPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final queryPermission = await _audioQuery.permissionsStatus();

    if (queryPermission) {
      return true;
    }

    final audioGranted = await Permission.audio.isGranted;
    final storageGranted = await Permission.storage.isGranted;

    return audioGranted || storageGranted;
  }

  Future<List<SongModel>> getSongs() async {
    return _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
  }

  Future<bool> openSettings() async {
    return openAppSettings();
  }
}