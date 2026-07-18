import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app/app.dart';
import 'core/audio/audio_handler.dart';
import 'core/audio/providers/audio_handler_provider.dart';
import 'features/player/providers/player_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final handler = await AudioService.init(
    builder: FluteAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.amitsharma.flute.audio',
      androidNotificationChannelName: 'Flute playback',
      androidNotificationChannelDescription:
          'Playback controls for music playing in Flute.',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: false,
      androidShowNotificationBadge: false,
    ),
  );

  final session = await AudioSession.instance;
  await session.configure(AudioSessionConfiguration.music());

  if (Platform.isAndroid) {
    await Permission.notification.request();
  }

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(handler),
        audioPlayerProvider.overrideWithValue(handler.service),
      ],
      child: const FluteApp(),
    ),
  );
}
