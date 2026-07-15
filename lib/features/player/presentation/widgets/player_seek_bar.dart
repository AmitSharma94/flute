import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/playback_position_provider.dart';
import '../../providers/player_provider.dart';

class PlayerSeekBar extends ConsumerWidget {
  const PlayerSeekBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final position =
        ref.watch(positionProvider).value ?? Duration.zero;

    final duration =
        ref.watch(durationProvider).value ??
            Duration.zero;

    final max =
        duration.inSeconds > 0
            ? duration.inSeconds.toDouble()
            : 1;

    return Column(
      children: [

        Slider(
  value: (position.inSeconds.toDouble()
          .clamp(0.0, max))
      .toDouble(),

  max: max.toDouble(),

  onChanged: (value) {
    ref
        .read(audioPlayerProvider)
        .player
        .seek(
          Duration(
            seconds: value.toInt(),
          ),
        );
  },
),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

          children: [

            Text(
              _format(position),
            ),

            Text(
              _format(duration),
            ),

          ],
        ),
      ],
    );
  }

  String _format(Duration duration) {

    String two(int n) =>
        n.toString().padLeft(2, '0');

    return '${two(duration.inMinutes)}:${two(duration.inSeconds % 60)}';
  }
}