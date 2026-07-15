import 'package:go_router/go_router.dart';
import '../../features/player/presentation/pages/player_page.dart';


final appRouter = GoRouter(
  routes: [
   GoRoute(
 path: '/player',
 builder: (context,state)=> const PlayerPage(),
),
  ],
);