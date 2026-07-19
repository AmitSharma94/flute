import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/audio_effects_provider.dart';

class AudioEffectsPage extends ConsumerWidget {
  const AudioEffectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(audioEffectsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Audio enhancements')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Audio effects unavailable: $error')),
        data: (state) {
          if (!state.supported) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Start playing a song to activate audio enhancements. '
                  'Availability varies by Android device.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              Text('Loudness boost', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              const Text('Adds up to +6 dB. High settings may cause distortion.'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable loudness boost'),
                value: state.loudnessEnabled,
                onChanged: state.loudnessSupported
                    ? (value) => ref.read(audioEffectsProvider.notifier).setLoudness(
                          value,
                          state.loudnessGainMb,
                        )
                    : null,
              ),
              Slider(
                min: 0,
                max: 600,
                divisions: 12,
                label: '+${(state.loudnessGainMb / 100).toStringAsFixed(1)} dB',
                value: state.loudnessGainMb.clamp(0, 600).toDouble(),
                onChanged: state.loudnessEnabled
                    ? (value) => ref.read(audioEffectsProvider.notifier).setLoudness(
                          true,
                          value.round(),
                        )
                    : null,
              ),
              const Divider(height: 40),
              Text('Flute Spatial', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              const Text('Generic stereo spatial effect; best used with headphones.'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable spatial effect'),
                value: state.spatialEnabled,
                onChanged: state.spatialSupported
                    ? (value) => ref.read(audioEffectsProvider.notifier).setSpatial(
                          value,
                          state.spatialStrength,
                        )
                    : null,
              ),
              Slider(
                min: 0,
                max: 1000,
                divisions: 20,
                label: '${(state.spatialStrength / 10).round()}%',
                value: state.spatialStrength.clamp(0, 1000).toDouble(),
                onChanged: state.spatialEnabled
                    ? (value) => ref.read(audioEffectsProvider.notifier).setSpatial(
                          true,
                          value.round(),
                        )
                    : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Dolby and SRS are proprietary technologies. Flute does not claim '
                'or bundle those processors; supported device effects may still apply.',
              ),
            ],
          );
        },
      ),
    );
  }
}
