import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../favorites/providers/favorite_provider.dart';
import '../../../history/providers/history_provider.dart';
import '../../../music/providers/music_provider.dart';
import '../../../player/helpers/play_song.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(musicLibraryProvider);
    final favorites = ref.watch(favoriteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          library.maybeWhen(
            data: (state) => PopupMenuButton<MusicSortMode>(
              tooltip: 'Sort library',
              initialValue: state.sortMode,
              onSelected: ref.read(musicLibraryProvider.notifier).setSortMode,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: MusicSortMode.title,
                  child: Text('Title'),
                ),
                PopupMenuItem(
                  value: MusicSortMode.artist,
                  child: Text('Artist'),
                ),
                PopupMenuItem(
                  value: MusicSortMode.album,
                  child: Text('Album'),
                ),
                PopupMenuItem(
                  value: MusicSortMode.duration,
                  child: Text('Duration'),
                ),
              ],
              icon: const Icon(Icons.sort),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'Refresh music',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(musicLibraryProvider.notifier).refresh(),
          ),
        ],
      ),
      body: library.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _LibraryError(
          message: 'flute_rc_V1 could not scan your music library.\n$error',
          onRetry: () =>
              ref.read(musicLibraryProvider.notifier).refresh(),
        ),
        data: (state) {
          if (state.permission == MusicPermissionState.denied) {
            return _PermissionRequired(
              onTryAgain: () => ref
                  .read(musicLibraryProvider.notifier)
                  .refresh(requestPermission: true),
              onOpenSettings: () =>
                  ref.read(musicLibraryProvider.notifier).openSettings(),
            );
          }

          if (state.songs.isEmpty) {
            return _EmptyLibrary(
              onRefresh: () =>
                  ref.read(musicLibraryProvider.notifier).refresh(),
            );
          }

          final availableIds = state.songs.map((song) => song.id).toSet();
          Future<void>.microtask(() async {
            await ref
                .read(favoriteProvider.notifier)
                .removeUnavailable(availableIds);
            await ref
                .read(historyProvider.notifier)
                .removeUnavailable(availableIds);
          });

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(musicLibraryProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: state.songs.length,
              itemBuilder: (context, index) {
                final song = state.songs[index];
                final isFavorite = favorites.contains(song);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${song.artist} • ${song.album}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => playSong(ref, state.songs, index),
                    trailing: IconButton(
                      tooltip: isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                      onPressed: () => ref
                          .read(favoriteProvider.notifier)
                          .toggle(song),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PermissionRequired extends StatelessWidget {
  const _PermissionRequired({
    required this.onTryAgain,
    required this.onOpenSettings,
  });

  final VoidCallback onTryAgain;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.library_music_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'Music permission required',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Allow flute_rc_V1 to read audio files stored on this device. flute_rc_V1 does not upload your music.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onTryAgain,
              icon: const Icon(Icons.lock_open),
              label: const Text('Allow access'),
            ),
            TextButton(
              onPressed: onOpenSettings,
              child: const Text('Open app settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * .22),
          const Icon(Icons.music_off_outlined, size: 64),
          const SizedBox(height: 16),
          Text(
            'No songs found',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Add audio files to your device, then pull down or tap refresh to scan again.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryError extends StatelessWidget {
  const _LibraryError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
