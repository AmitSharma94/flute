import 'package:go_router/go_router.dart';

import '../../core/shell/main_shell.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShell(),
    ),
  ],
);