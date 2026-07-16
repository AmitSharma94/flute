import 'package:flutter_riverpod/flutter_riverpod.dart';


enum FluteRepeatMode {

  off,

  one,

  all,

}



class RepeatNotifier extends Notifier<FluteRepeatMode> {


  @override
  FluteRepeatMode build() {

    return FluteRepeatMode.off;

  }



  void toggle() {

    switch (state) {

      case FluteRepeatMode.off:

        state = FluteRepeatMode.all;

        break;


      case FluteRepeatMode.all:

        state = FluteRepeatMode.one;

        break;


      case FluteRepeatMode.one:

        state = FluteRepeatMode.off;

        break;

    }

  }

}



final repeatProvider =
    NotifierProvider<RepeatNotifier, FluteRepeatMode>(
  RepeatNotifier.new,
);