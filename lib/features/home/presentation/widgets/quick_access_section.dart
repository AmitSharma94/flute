import 'package:flutter/material.dart';

class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Access",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          Row(
            children: const [
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.favorite_outline,
                  title: "Favorites",
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.album_outlined,
                  title: "Albums",
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: const [
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.person_outline,
                  title: "Artists",
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.history,
                  title: "Recently Played",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 34,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}