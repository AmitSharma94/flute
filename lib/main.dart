import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app/app.dart';



Future<void> main() async {


  WidgetsFlutterBinding.ensureInitialized();



  await JustAudioBackground.init(


    androidNotificationChannelId:

        'com.flute.music.player',



    androidNotificationChannelName:

        'Flute Music Playback',



    androidNotificationOngoing:

        true,


  );



  runApp(


    const ProviderScope(


      child:

          FluteApp(),


    ),


  );


}