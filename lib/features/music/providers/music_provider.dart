import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/song_model.dart';
import '../data/services/audio_scanner_service.dart';

final audioScannerProvider = Provider<AudioScannerService>((ref) {
  return AudioScannerService();
});

final songsProvider = FutureProvider<List<FluteSong>>((ref) async {
  final scanner = ref.read(audioScannerProvider);

  final permission = await scanner.requestPermission();

  if (!permission) {
    return [];
  }

  return scanner.getSongs();
});