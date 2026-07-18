import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/constants/app_info.dart';

import '../features/settings/providers/settings_provider.dart';
import '../features/player/providers/playback_controller.dart';

class FluteApp extends ConsumerWidget {
  const FluteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    ref.watch(playbackControllerProvider);

    return settings.when(
      loading: () => MaterialApp.router(
        title: AppInfo.displayName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: appRouter,
      ),

      error: (error, stackTrace) => MaterialApp.router(
        title: AppInfo.displayName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: appRouter,
      ),

      data: (state) {
        return MaterialApp.router(
          title: AppInfo.displayName,
          debugShowCheckedModeBanner: false,

          theme: AppTheme.light,

          darkTheme: AppTheme.dark,

          themeMode: state.themeMode,

          routerConfig: appRouter,
        );
      },
    );
  }
}
