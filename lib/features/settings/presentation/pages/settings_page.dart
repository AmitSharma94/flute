import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _sectionTitle(
    BuildContext context,
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        12,
      ),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _card({
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Settings",
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          bottom: 30,
        ),
        children: [

          const SizedBox(height: 10),

          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: color.primaryContainer,
              child: Icon(
                Icons.music_note_rounded,
                size: 42,
                color: color.primary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              "Flute",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          Center(
            child: Text(
              "Version 0.1.0-alpha.1",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ),

          _sectionTitle(
            context,
            "Appearance",
          ),

          _card(
            children: [

              ListTile(
                leading: const Icon(
                  Icons.palette_outlined,
                ),
                title: const Text(
                  "Theme",
                ),
                subtitle: const Text(
                  "System",
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Theme selector coming soon",
                      ),
                    ),
                  );
                },
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(
                  Icons.color_lens_outlined,
                ),
                title: const Text(
                  "Material You",
                ),
                subtitle: const Text(
                  "Dynamic colors",
                ),
                trailing: Switch(
                  value: false,
                  onChanged: null,
                ),
              ),
            ],
          ),

          _sectionTitle(
            context,
            "Playback",
          ),

          _card(
            children: [

              SwitchListTile(
                value: false,
                onChanged: null,
                secondary: const Icon(
                  Icons.play_circle_outline,
                ),
                title: const Text(
                  "Resume Playback",
                ),
                subtitle: const Text(
                  "Coming soon",
                ),
              ),

              const Divider(height: 1),

              SwitchListTile(
                value: false,
                onChanged: null,
                secondary: const Icon(
                  Icons.shuffle,
                ),
                title: const Text(
                  "Shuffle by Default",
                ),
                subtitle: const Text(
                  "Coming soon",
                ),
              ),

              const Divider(height: 1),

              SwitchListTile(
                value: false,
                onChanged: null,
                secondary: const Icon(
                  Icons.repeat,
                ),
                title: const Text(
                  "Repeat Playback",
                ),
                subtitle: const Text(
                  "Coming soon",
                ),
              ),

              const Divider(height: 1),

              SwitchListTile(
                value: false,
                onChanged: null,
                secondary: const Icon(
                  Icons.graphic_eq,
                ),
                title: const Text(
                  "Gapless Playback",
                ),
                subtitle: const Text(
                  "Coming soon",
                ),
              ),
            ],
          ),

          _sectionTitle(
            context,
            "Library",
          ),

          _card(
            children: [

              ListTile(
                leading: const Icon(
                  Icons.refresh,
                ),
                title: const Text(
                  "Rescan Library",
                ),
                subtitle: const Text(
                  "Find newly added songs",
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Library scan coming soon",
                      ),
                    ),
                  );
                },
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(
                  Icons.folder_outlined,
                ),
                title: const Text(
                  "Music Folders",
                ),
                subtitle: const Text(
                  "Manage scan locations",
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {},
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(
                  Icons.history,
                ),
                title: const Text(
                  "Clear Recently Played",
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {},
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(
                  Icons.search_off,
                ),
                title: const Text(
                  "Clear Search History",
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {},
              ),
            ],
          ),

          _sectionTitle(
            context,
            "About",
          ),

          _card(
            children: [

              const AboutListTile(
                icon: Icon(
                  Icons.info_outline,
                ),
                applicationName: "Flute",
                applicationVersion:
                    "0.1.0-alpha.1",
                applicationLegalese:
                    "© 2026 Amit Sharma",
              ),

              const Divider(height: 1),

              ListTile(
                leading: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                title: const Text(
                  "Made with ❤️ by Amit Sharma",
                ),
                subtitle: const Text(
                  "Thank you for using Flute",
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}