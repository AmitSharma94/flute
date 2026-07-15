import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class FluteApp extends StatelessWidget {
  const FluteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flute',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}