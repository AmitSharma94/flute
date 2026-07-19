import 'dart:io';

import 'package:flutter/services.dart';

class RingtoneResult {
  const RingtoneResult({required this.success, required this.needsPermission});
  final bool success;
  final bool needsPermission;
}

class RingtoneService {
  static const _channel = MethodChannel('com.amitsharma.flute/ringtone');

  Future<bool> canWriteSettings() async {
    if (!Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('canWriteSettings') ?? false;
  }

  Future<void> requestWriteSettings() => _channel.invokeMethod<void>('requestWriteSettings');

  Future<RingtoneResult> setRingtone({
    required String path,
    required String title,
    required String type,
  }) async {
    final map = await _channel.invokeMapMethod<Object?, Object?>('setRingtone', {
      'path': path,
      'title': title,
      'type': type,
    });
    return RingtoneResult(
      success: map?['success'] as bool? ?? false,
      needsPermission: map?['needsPermission'] as bool? ?? false,
    );
  }
}
