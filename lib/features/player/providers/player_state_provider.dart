import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'player_provider.dart';

final playerStateProvider =
    StreamProvider<PlayerState>((ref) {

  final player =
      ref.watch(audioPlayerProvider);

  return player.playerStateStream;

});