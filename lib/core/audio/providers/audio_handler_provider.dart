import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio_handler.dart';

final audioHandlerProvider = Provider<FluteAudioHandler>((ref) {
  throw StateError('FluteAudioHandler must be overridden in main.dart.');
});
