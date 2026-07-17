import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'queue_controller.dart';

final queueControllerProvider = Provider<QueueController>((ref) {
  return QueueController(ref);
});
