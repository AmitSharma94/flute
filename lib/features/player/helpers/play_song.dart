import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../music/data/models/song_model.dart';
import '../providers/playback_controller.dart';

Future<void> playSong(
  WidgetRef ref,
  List<FluteSong> queue,
  int index,
) {
  return ref
      .read(playbackControllerProvider)
      .setQueueAndPlay(queue, index);
}
