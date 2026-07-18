import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/song_tile.dart';
import '../../../favorites/providers/favorite_provider.dart';
import '../../../music/data/models/song_model.dart';
import '../../../player/providers/playback_controller.dart';
import '../../data/services/hq_audio_service.dart';

class OnlineMusicPage extends ConsumerStatefulWidget {
  const OnlineMusicPage({super.key});

  @override
  ConsumerState<OnlineMusicPage> createState() => _OnlineMusicPageState();
}

class _OnlineMusicPageState extends ConsumerState<OnlineMusicPage> {
  final _controller = TextEditingController();
  List<FluteSong> _results = const [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    final query = _controller.text.trim();
    if (query.isEmpty || _loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final songs = await ref.read(hqAudioServiceProvider).searchSongs(query);
      if (!mounted) return;
      setState(() {
        _results = songs;
        if (songs.isEmpty) {
          _error = 'No online results were found for “$query”.';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to search HQ Audio. $error';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoriteProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Online Music')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              controller: _controller,
              hintText: 'Search songs, artists, or albums',
              leading: const Icon(Icons.search),
              trailing: [
                if (_controller.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear',
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        _results = const [];
                        _error = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                IconButton(
                  tooltip: 'Search',
                  onPressed: _loading ? null : _search,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _search(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Text(
              'Online results are provided by the configured HQ Audio service. Availability depends on that service and your connection.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(child: _content(favorites)),
        ],
      ),
    );
  }

  Widget _content(List<FluteSong> favorites) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 52),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loading ? null : _search,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Search for online music. Tap a result to resolve its stream and play it.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 180),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final song = _results[index];
        return SongTile(
          song: song,
          isFavorite: favorites.contains(song),
          onFavorite: () => ref.read(favoriteProvider.notifier).toggle(song),
          onTap: () => ref
              .read(playbackControllerProvider)
              .setQueueAndPlay(_results, index),
        );
      },
    );
  }
}
