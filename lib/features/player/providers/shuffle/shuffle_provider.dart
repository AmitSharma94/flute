import 'package:flutter_riverpod/flutter_riverpod.dart';


class ShuffleNotifier extends Notifier<bool> {


  @override
  bool build() {

    return false;

  }



  void toggle() {

    state = !state;

  }


}



final shuffleProvider =
    NotifierProvider<ShuffleNotifier, bool>(
  ShuffleNotifier.new,
);