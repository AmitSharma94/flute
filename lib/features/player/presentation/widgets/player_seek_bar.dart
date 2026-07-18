import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/playback_controller.dart';
import '../../providers/playback_position_provider.dart';

class PlayerSeekBar extends ConsumerWidget {
  const PlayerSeekBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final duration = ref.watch(durationProvider).value ?? Duration.zero;
    final maximum = duration.inMilliseconds > 0
        ? duration.inMilliseconds.toDouble()
        : 1.0;
    final current = position.inMilliseconds.toDouble().clamp(0.0, maximum);

    return Column(
      children: [
        Slider(
          value: current,
          max: maximum,
          onChanged: duration == Duration.zero
              ? null
              : (value) => ref
                    .read(playbackControllerProvider)
                    .seek(Duration(milliseconds: value.round())),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(_format(position)), Text(_format(duration))],
        ),
      ],
    );
  }

  String _format(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}
