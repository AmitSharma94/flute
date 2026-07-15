import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';

import 'app/app.dart';
import 'core/audio/audio_handler.dart';
import 'core/audio/providers/audio_handler_provider.dart';

late FluteAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  audioHandler = await AudioService.init(
    builder: () => FluteAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.flute.audio',
      androidNotificationChannelName: 'Flute Music',
      androidNotificationOngoing: true,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(
          audioHandler,
        ),
      ],
      child: const FluteApp(),
    ),
  );
}