import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShuffleNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void setEnabled(bool value) => state = value;
}

final shuffleProvider = NotifierProvider<ShuffleNotifier, bool>(
  ShuffleNotifier.new,
);
