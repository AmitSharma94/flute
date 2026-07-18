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

  final audioHandler = await AudioService.init(
    builder: FluteAudioHandler.new,
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.amitsharma.flute.channel.audio',
      androidNotificationChannelName: 'Flute playback',
      androidNotificationChannelDescription:
          'Playback controls for music playing in Flute.',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: false,
      androidShowNotificationBadge: false,
    ),
  );

  final audioSession = await AudioSession.instance;

  await audioSession.configure(AudioSessionConfiguration.music());

  if (Platform.isAndroid) {
    final status = await Permission.notification.status;

    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
        audioPlayerProvider.overrideWithValue(audioHandler.service),
      ],
      child: const FluteApp(),
    ),
  );
}
