import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../player/providers/playback_controller.dart';
import '../../../../shared/widgets/song_tile.dart';
import '../../data/services/jiosaavn_service.dart';
import '../../../music/data/models/song_model.dart';

class OnlineMusicPage extends ConsumerStatefulWidget {
  const OnlineMusicPage({super.key});

  @override
  ConsumerState<OnlineMusicPage> createState() => _OnlineMusicPageState();
}

class _OnlineMusicPageState extends ConsumerState<OnlineMusicPage> {
  final _controller = TextEditingController();
  final _service = JioSaavnService();
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
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final songs = await _service.searchSongs(_controller.text);
      if (!mounted) return;
      setState(() => _results = songs);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Unable to search online music. $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Online')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              controller: _controller,
              hintText: 'Search JioSaavn',
              leading: const Icon(Icons.search),
              trailing: [
                IconButton(
                  tooltip: 'Search',
                  onPressed: _loading ? null : _search,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
              onSubmitted: (_) => _search(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Text(
              'Private-use integration through an unofficial API. Availability may change. Music rights remain with their respective owners.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(child: _content()),
        ],
      ),
    );
  }

  Widget _content() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    if (_results.isEmpty) {
      return const Center(child: Text('Search for a song, artist, or album.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 180),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final song = _results[index];
        return SongTile(
          song: song,
          onTap: () => ref
              .read(playbackControllerProvider)
              .setQueueAndPlay(_results, index),
        );
      },
    );
  }
}
