import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_info.dart';
import '../../../player/providers/repeat/repeat_provider.dart';
import '../../../player/providers/shuffle/shuffle_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/settings_card.dart';
import '../../widgets/settings_header.dart';
import '../../widgets/settings_section.dart';
import '../../widgets/settings_switch_tile.dart';
import '../../widgets/settings_tile.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _SettingsError(
          message: error.toString(),
          onRetry: () => ref.invalidate(settingsProvider),
        ),
        data: (settings) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(settingsProvider);
            await ref.read(settingsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 180),
            children: [
              const SettingsHeader(),
              const SettingsSection(title: 'Appearance'),
              SettingsCard(
                children: [
                  SettingsTile(
                    icon: _themeIcon(settings.themeMode),
                    title: 'Theme',
                    subtitle: _themeLabel(settings.themeMode),
                    onTap: () => _showThemePicker(
                      context,
                      ref,
                      settings.themeMode,
                    ),
                  ),
                ],
              ),
              const SettingsSection(title: 'Playback'),
              SettingsCard(
                children: [
                  SettingsSwitchTile(
                    icon: Icons.restore_rounded,
                    title: 'Resume playback',
                    subtitle: 'Continue from the previous session',
                    value: settings.resumePlayback,
                    onChanged: (value) => ref
                        .read(settingsProvider.notifier)
                        .setResumePlayback(value),
                  ),
                  const Divider(height: 1, indent: 76),
                  SettingsSwitchTile(
                    icon: Icons.shuffle_rounded,
                    title: 'Shuffle by default',
                    subtitle: 'Start new queues in shuffle mode',
                    value: settings.shuffleDefault,
                    onChanged: (value) async {
                      await ref
                          .read(settingsProvider.notifier)
                          .setShuffleDefault(value);
                      ref.read(shuffleProvider.notifier).setEnabled(value);
                    },
                  ),
                  const Divider(height: 1, indent: 76),
                  SettingsSwitchTile(
                    icon: Icons.repeat_rounded,
                    title: 'Repeat by default',
                    subtitle: 'Repeat the queue when it finishes',
                    value: settings.repeatDefault,
                    onChanged: (value) async {
                      await ref
                          .read(settingsProvider.notifier)
                          .setRepeatDefault(value);
                      ref.read(repeatProvider.notifier).setMode(
                            value
                                ? FluteRepeatMode.all
                                : FluteRepeatMode.off,
                          );
                    },
                  ),
                  const Divider(height: 1, indent: 76),
                  SettingsSwitchTile(
                    icon: Icons.screen_lock_portrait_rounded,
                    title: 'Keep screen awake',
                    subtitle: 'Keep the display active on the player screen',
                    value: settings.keepScreenAwake,
                    onChanged: (value) => ref
                        .read(settingsProvider.notifier)
                        .setKeepScreenAwake(value),
                  ),
                ],
              ),
              const SettingsSection(title: 'App'),
              SettingsCard(
                children: [
                  SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About ${AppInfo.displayName}',
                    subtitle: 'Version ${AppInfo.version}',
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: AppInfo.displayName,
                      applicationVersion: AppInfo.version,
                      applicationLegalese: AppInfo.legalese,
                      applicationIcon: Icon(
                        Icons.music_note_rounded,
                        size: 46,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 76),
                  SettingsTile(
                    icon: Icons.restart_alt_rounded,
                    title: 'Reset settings',
                    subtitle: 'Restore the default preferences',
                    onTap: () => _confirmReset(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.settings_brightness_rounded;
    }
  }

  static String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Use device setting';
    }
  }

  Future<void> _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode selectedMode,
  ) async {
    final mode = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose theme',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              RadioListTile<ThemeMode>(
                value: ThemeMode.system,
                groupValue: selectedMode,
                title: const Text('System default'),
                secondary: const Icon(Icons.settings_brightness_rounded),
                onChanged: (value) => Navigator.pop(context, value),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                groupValue: selectedMode,
                title: const Text('Light'),
                secondary: const Icon(Icons.light_mode_rounded),
                onChanged: (value) => Navigator.pop(context, value),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: selectedMode,
                title: const Text('Dark'),
                secondary: const Icon(Icons.dark_mode_rounded),
                onChanged: (value) => Navigator.pop(context, value),
              ),
            ],
          ),
        ),
      ),
    );

    if (mode != null) {
      await ref.read(settingsProvider.notifier).setThemeMode(mode);
    }
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset settings?'),
        content: const Text(
          'Theme and playback preferences will return to their defaults.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(settingsProvider.notifier).resetToDefaults();
    ref.read(shuffleProvider.notifier).setEnabled(false);
    ref.read(repeatProvider.notifier).setMode(FluteRepeatMode.off);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings reset')),
      );
    }
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Could not load settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
