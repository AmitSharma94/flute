import 'dart:io';

import 'package:native_audio_trimmer/native_audio_trimmer.dart';
import 'package:path_provider/path_provider.dart';

class RingtoneCropService {
  static const Duration clipLength = Duration(seconds: 30);

  Future<String> crop({
    required String inputPath,
    required Duration start,
    required Duration sourceDuration,
    required String title,
  }) async {
    final source = File(inputPath);
    if (!await source.exists()) {
      throw StateError('The selected song file no longer exists.');
    }

    final safeDuration = sourceDuration > Duration.zero
        ? sourceDuration
        : clipLength;
    final latestStart = safeDuration > clipLength
        ? safeDuration - clipLength
        : Duration.zero;
    final safeStart = start < Duration.zero
        ? Duration.zero
        : start > latestStart
        ? latestStart
        : start;
    final end = safeStart +
        (safeDuration - safeStart < clipLength
            ? safeDuration - safeStart
            : clipLength);

    if (end <= safeStart) {
      throw StateError('The selected song is too short to crop.');
    }

    final directory = await getApplicationDocumentsDirectory();
    final ringtoneDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}ringtone_clips',
    );
    await ringtoneDirectory.create(recursive: true);

    final safeTitle = title
        .replaceAll(RegExp(r'[^A-Za-z0-9 _-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath =
        '${ringtoneDirectory.path}${Platform.pathSeparator}'
        '${safeTitle.isEmpty ? 'Flute_ringtone' : safeTitle}_$timestamp.m4a';

    final result = await NativeAudioTrimmer.trimAudio(
      inputPath: source.path,
      outputPath: outputPath,
      startTimeInSeconds: safeStart.inMilliseconds / 1000,
      endTimeInSeconds: end.inMilliseconds / 1000,
    );

    final output = File(result);
    if (!await output.exists() || await output.length() == 0) {
      throw StateError('The ringtone clip could not be created.');
    }
    return output.path;
  }
}
