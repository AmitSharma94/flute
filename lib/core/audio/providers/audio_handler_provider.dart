import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/player/providers/player_provider.dart';
import '../audio_handler.dart';

final audioHandlerProvider = Provider<FluteAudioHandler>((ref) {
  return FluteAudioHandler(ref.watch(audioPlayerProvider));
});
