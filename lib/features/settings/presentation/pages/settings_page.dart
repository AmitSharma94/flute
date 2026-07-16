import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget buildSectionTitle(
    BuildContext context,
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          buildSectionTitle(
            context,
            "Playback",
          ),

          SwitchListTile(
            value: false,
            onChanged: null,
            title: const Text("Gapless Playback"),
            subtitle: const Text("Coming soon"),
          ),

          SwitchListTile(
            value: false,
            onChanged: null,
            title: const Text("Shuffle by Default"),
            subtitle: const Text("Coming soon"),
          ),

          SwitchListTile(
            value: false,
            onChanged: null,
            title: const Text("Resume on Launch"),
            subtitle: const Text("Coming soon"),
          ),

          buildSectionTitle(
            context,
            "Appearance",
          ),

          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text("Theme"),
            subtitle: const Text("System"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          buildSectionTitle(
            context,
            "Library",
          ),

          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text("Rescan Library"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.sort),
            title: const Text("Sort Songs"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          buildSectionTitle(
            context,
            "About",
          ),

          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: "Flute",
            applicationVersion: "Alpha 1",
            applicationLegalese: "© 2026",
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}