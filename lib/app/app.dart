import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

import '../features/settings/providers/settings_provider.dart';

class FluteApp extends ConsumerWidget {
  const FluteApp({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final settings = ref.watch(settingsProvider);

    return settings.when(
      loading: () => MaterialApp.router(
        title: 'Flute',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: appRouter,
      ),

      error: (error, stackTrace) => MaterialApp.router(
        title: 'Flute',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: appRouter,
      ),

      data: (state) {
        return MaterialApp.router(
          title: 'Flute',
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