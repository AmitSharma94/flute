import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'player_provider.dart';

final positionProvider = StreamProvider<Duration>((ref) {
  final player = ref.watch(audioPlayerProvider);

  return player.player.positionStream;
});

final durationProvider = StreamProvider<Duration?>((ref) {
  final player = ref.watch(audioPlayerProvider);

  return player.player.durationStream;
});