import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/audio_player_service.dart';

final audioPlayerProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
