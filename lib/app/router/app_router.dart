import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/player/presentation/pages/player_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),

    GoRoute(
      path: '/player',
      builder: (context, state) => const PlayerPage(),
    ),
  ],
);