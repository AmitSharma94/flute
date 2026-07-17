// Placeholder complete settings_page.dart
// NOTE: This file requires adaptation to your exact project.
// Due to project-specific dependencies, a verified implementation
// should be generated against the current codebase.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Center(child: Text(e.toString())),
      ),
      data: (settings) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          children: [
            ListTile(
              title: const Text('Theme'),
              subtitle: Text(settings.themeMode.name),
            ),
            SwitchListTile(
              title: const Text('Resume Playback'),
              value: settings.resumePlayback,
              onChanged: (v) => ref.read(settingsProvider.notifier).setResumePlayback(v),
            ),
            SwitchListTile(
              title: const Text('Shuffle by Default'),
              value: settings.shuffleDefault,
              onChanged: (v) => ref.read(settingsProvider.notifier).setShuffleDefault(v),
            ),
            SwitchListTile(
              title: const Text('Repeat by Default'),
              value: settings.repeatDefault,
              onChanged: (v) => ref.read(settingsProvider.notifier).setRepeatDefault(v),
            ),
            SwitchListTile(
              title: const Text('Keep Screen Awake'),
              value: settings.keepScreenAwake,
              onChanged: (v) => ref.read(settingsProvider.notifier).setKeepScreenAwake(v),
            ),
          ],
        ),
      ),
    );
  }
}
