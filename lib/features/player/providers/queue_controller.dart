import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'playback_controller.dart';

/// Compatibility wrapper for existing widgets.
/// New playback behavior is centralized in [PlaybackController].
class QueueController {
  QueueController(this.ref);

  final Ref ref;

  Future<void> playIndex(int newIndex) =>
      ref.read(playbackControllerProvider).playIndex(newIndex);

  Future<void> next() => ref.read(playbackControllerProvider).next();

  Future<void> previous() => ref.read(playbackControllerProvider).previous();
}
