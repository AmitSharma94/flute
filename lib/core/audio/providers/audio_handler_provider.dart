import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio_handler.dart';

final audioHandlerProvider = Provider<FluteAudioHandler>((ref) {
  return FluteAudioHandler();
});