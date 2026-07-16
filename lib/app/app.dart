import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/player/providers/auto_next/auto_next_provider.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';


class FluteApp extends ConsumerWidget {

  const FluteApp({
    super.key,
  });



  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {


    // Activates automatic next song listener
    ref.watch(
      autoNextProvider,
    );



    return MaterialApp.router(

      title: 'Flute',

      debugShowCheckedModeBanner: false,

      theme:
          AppTheme.dark,

      routerConfig:
          appRouter,

    );

  }

}