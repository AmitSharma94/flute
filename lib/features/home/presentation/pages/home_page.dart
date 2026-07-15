import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flute'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Good Morning',
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 24),

          Text(
            'Continue Listening',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _albumCard(Icons.album, 'Recently Played'),
                _albumCard(Icons.music_note, 'Favorites'),
                _albumCard(Icons.queue_music, 'Playlist'),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'Quick Access',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          _menuCard(
            context,
            Icons.library_music,
            'All Songs',
          ),

          _menuCard(
            context,
            Icons.album,
            'Albums',
          ),

          _menuCard(
            context,
            Icons.person,
            'Artists',
          ),

          _menuCard(
            context,
            Icons.folder,
            'Folders',
          ),

          _menuCard(
            context,
            Icons.favorite,
            'Favorites',
          ),

          const SizedBox(height: 28),

          Text(
            'Recently Added',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('No songs yet'),
              subtitle: const Text(
                'Your offline music will appear here',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _albumCard(IconData icon, String title) {
    return Card(
      child: SizedBox(
        width: 130,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: () {},
      ),
    );
  }
}