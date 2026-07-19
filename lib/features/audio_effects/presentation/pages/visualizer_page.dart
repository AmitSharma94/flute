import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers/audio_effects_provider.dart';

class VisualizerPage extends ConsumerStatefulWidget {
  const VisualizerPage({super.key});

  @override
  ConsumerState<VisualizerPage> createState() => _VisualizerPageState();
}

class _VisualizerPageState extends ConsumerState<VisualizerPage> {
  Timer? _timer;
  List<int> _waveform = const [];
  String? _message;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) setState(() => _message = 'Microphone permission is required by Android for playback visualization. Flute does not record or save microphone audio.');
      return;
    }
    final service = ref.read(audioEffectsServiceProvider);
    final started = await service.startVisualizer();
    if (!started) {
      if (mounted) setState(() => _message = 'Start playing a song, then reopen the visualizer. This device may not support the Android visualizer effect.');
      return;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) async {
      final frame = await service.getVisualizerFrame();
      if (mounted && frame.isNotEmpty) setState(() => _waveform = frame);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(ref.read(audioEffectsServiceProvider).stopVisualizer());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visualizer')),
      body: Center(
        child: _message != null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_message!, textAlign: TextAlign.center),
              )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: CustomPaint(
                  painter: _WaveformPainter(_waveform, Theme.of(context).colorScheme.primary),
                  size: Size.infinite,
                ),
              ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter(this.values, this.color);
  final List<int> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final mid = size.height / 2;
    if (values.length < 2) {
      canvas.drawLine(Offset(0, mid), Offset(size.width, mid), paint);
      return;
    }
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final x = index * size.width / (values.length - 1);
      final normalized = (values[index] - 128) / 128;
      final y = mid + normalized * size.height * 0.42;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => oldDelegate.values != values || oldDelegate.color != color;
}
