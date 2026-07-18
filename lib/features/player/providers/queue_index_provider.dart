import 'package:flutter_riverpod/flutter_riverpod.dart';

class QueueIndexNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void setIndex(int index) {
    state = index;
  }
}

final queueIndexProvider =
    NotifierProvider<QueueIndexNotifier, int>(
  QueueIndexNotifier.new,
);