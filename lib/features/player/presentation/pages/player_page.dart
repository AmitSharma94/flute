import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../favorites/providers/favorite_provider.dart';
import '../../../music/presentation/widgets/song_artwork.dart';
import '../../providers/current_song_provider.dart';
import '../../providers/playback_controller.dart';
import '../../providers/player_state_provider.dart';
import '../../providers/repeat/repeat_provider.dart';
import '../../providers/shuffle/shuffle_provider.dart';
import '../widgets/player_seek_bar.dart';
import 'queue/queue_page.dart';

class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);
    if (song == null) {
      return const Scaffold(body: Center(child: Text('No song selected')));
    }

    final playerState = ref.watch(playerStateProvider);
    final busy = ref.watch(playbackBusyProvider);
    final shuffle = ref.watch(shuffleProvider);
    final repeat = ref.watch(repeatProvider);
    final controller = ref.read(playbackControllerProvider);
    final favorites = ref.watch(favoriteProvider);
    final isFavorite = favorites.contains(song);

    return Scaffold(
      body: SafeArea(
        child: playerState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(error.toString())),
          data: (state) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'NOW PLAYING',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                      onPressed: () =>
                          ref.read(favoriteProvider.notifier).toggle(song),
                    ),
                    IconButton(
                      tooltip: 'Queue',
                      icon: const Icon(Icons.queue_music),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QueuePage()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Hero(
                      tag: song.id,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: SongArtwork(id: song.id, imageUrl: song.artworkUrl, size: 320),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: PlayerSeekBar(),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      tooltip: shuffle ? 'Disable shuffle' : 'Enable shuffle',
                      icon: Icon(
                        Icons.shuffle,
                        color: shuffle
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: controller.toggleShuffle,
                    ),
                    IconButton(
                      tooltip: 'Previous',
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 42,
                      onPressed: busy ? null : controller.previous,
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(22),
                      ),
                      onPressed: busy ? null : controller.togglePlayPause,
                      child: busy
                          ? const SizedBox.square(
                              dimension: 34,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : Icon(
                              state.playing ? Icons.pause : Icons.play_arrow,
                              size: 38,
                            ),
                    ),
                    IconButton(
                      tooltip: 'Next',
                      icon: const Icon(Icons.skip_next),
                      iconSize: 42,
                      onPressed: busy ? null : controller.next,
                    ),
                    IconButton(
                      tooltip: _repeatTooltip(repeat),
                      icon: Icon(
                        repeat == FluteRepeatMode.one
                            ? Icons.repeat_one
                            : Icons.repeat,
                        color: repeat == FluteRepeatMode.off
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: controller.toggleRepeat,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _repeatTooltip(FluteRepeatMode mode) {
    switch (mode) {
      case FluteRepeatMode.off:
        return 'Repeat off';
      case FluteRepeatMode.all:
        return 'Repeat all';
      case FluteRepeatMode.one:
        return 'Repeat one';
    }
  }
}
