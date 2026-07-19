import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/equalizer_provider.dart';

class EqualizerPage extends ConsumerWidget {
  const EqualizerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(equalizerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Equalizer')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Equalizer unavailable: $error'),
          ),
        ),
        data: (state) {
          if (!state.supported) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Start playing a song to activate the Android equalizer. '
                  'Some devices do not expose system audio effects.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable equalizer'),
                subtitle: const Text('Applies to Flute playback only'),
                value: state.enabled,
                onChanged: (value) => ref
                    .read(equalizerProvider.notifier)
                    .setEnabled(value),
              ),
              if (state.presets.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: state.currentPreset >= 0
                      ? state.currentPreset
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Preset',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (var index = 0; index < state.presets.length; index++)
                      DropdownMenuItem(
                        value: index,
                        child: Text(state.presets[index]),
                      ),
                  ],
                  onChanged: state.enabled
                      ? (value) {
                          if (value != null) {
                            ref
                                .read(equalizerProvider.notifier)
                                .usePreset(value);
                          }
                        }
                      : null,
                ),
              ],
              const SizedBox(height: 28),
              for (final band in state.bands) ...[
                Text(
                  _frequencyLabel(band.centerFrequencyHz),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Slider(
                  min: state.minLevel.toDouble(),
                  max: state.maxLevel.toDouble(),
                  divisions: ((state.maxLevel - state.minLevel) ~/ 100)
                      .clamp(1, 100),
                  label: '${(band.level / 100).toStringAsFixed(1)} dB',
                  value: band.level
                      .clamp(state.minLevel, state.maxLevel)
                      .toDouble(),
                  onChanged: state.enabled
                      ? (value) => ref
                            .read(equalizerProvider.notifier)
                            .setBandLevel(band.index, value.round())
                      : null,
                ),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
      ),
    );
  }

  static String _frequencyLabel(int hz) {
    if (hz >= 1000) {
      final value = hz / 1000;
      return '${value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1)} kHz';
    }
    return '$hz Hz';
  }
}
