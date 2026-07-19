import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../music/data/models/song_model.dart';
import '../../data/ringtone_crop_service.dart';
import '../../data/ringtone_service.dart';

class RingtoneCropPage extends StatefulWidget {
  const RingtoneCropPage({
    super.key,
    required this.song,
  });

  final FluteSong song;

  @override
  State<RingtoneCropPage> createState() => _RingtoneCropPageState();
}

class _RingtoneCropPageState extends State<RingtoneCropPage> {
  final AudioPlayer _previewPlayer = AudioPlayer();
  final RingtoneCropService _cropService = RingtoneCropService();
  final RingtoneService _ringtoneService = RingtoneService();

  StreamSubscription<PlayerState>? _playerStateSubscription;
  double _startSeconds = 0;
  bool _isPreparing = false;
  bool _isPreviewing = false;
  String? _message;

  Duration get _songDuration => Duration(milliseconds: widget.song.duration);

  Duration get _clipDuration {
    if (_songDuration <= Duration.zero) {
      return RingtoneCropService.clipLength;
    }
    return _songDuration < RingtoneCropService.clipLength
        ? _songDuration
        : RingtoneCropService.clipLength;
  }

  double get _maximumStartSeconds {
    final maximum = _songDuration - _clipDuration;
    return maximum.isNegative ? 0 : maximum.inMilliseconds / 1000;
  }

  Duration get _start => Duration(
        milliseconds: (_startSeconds * 1000).round(),
      );

  Duration get _end => _start + _clipDuration;

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = _previewPlayer.playerStateStream.listen((state) {
      if (!mounted) {
        return;
      }
      final previewing = state.playing;
      if (_isPreviewing != previewing) {
        setState(() => _isPreviewing = previewing);
      }
    });
  }

  Future<void> _preview() async {
    try {
      if (_isPreviewing) {
        await _previewPlayer.stop();
        return;
      }
      setState(() => _message = null);
      await _previewPlayer.setFilePath(widget.song.path);
      await _previewPlayer.setClip(start: _start, end: _end);
      await _previewPlayer.seek(Duration.zero);
      await _previewPlayer.play();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _message = 'Preview failed: $error');
    }
  }

  Future<void> _createAndSetRingtone() async {
    if (_isPreparing) {
      return;
    }
    setState(() {
      _isPreparing = true;
      _message = null;
    });

    try {
      await _previewPlayer.stop();

      if (!await _ringtoneService.canWriteSettings()) {
        if (!mounted) {
          return;
        }
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Allow system setting changes'),
            content: const Text(
              'Android requires this permission before Flute can set the '
              'cropped clip as your ringtone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open settings'),
              ),
            ],
          ),
        );
        if (openSettings == true) {
          await _ringtoneService.requestWriteSettings();
        }
        return;
      }

      final croppedPath = await _cropService.crop(
        inputPath: widget.song.path,
        start: _start,
        sourceDuration: _songDuration,
        title: widget.song.title,
      );
      final result = await _ringtoneService.setRingtone(
        path: croppedPath,
        title: '${widget.song.title} (30s)',
        type: 'ringtone',
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _message = result.success
            ? 'The selected 30-second clip is now your ringtone.'
            : 'The clip was created, but Android could not set it.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _message = 'Could not create ringtone: $error');
    } finally {
      if (mounted) {
        setState(() => _isPreparing = false);
      }
    }
  }

  String _format(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    unawaited(_playerStateSubscription?.cancel());
    unawaited(_previewPlayer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create 30s ringtone')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.song.title,
            style: Theme.of(context).textTheme.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            widget.song.artist,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          Text(
            'Choose where the ringtone starts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Slider(
            value: _startSeconds.clamp(0, _maximumStartSeconds),
            min: 0,
            max: _maximumStartSeconds <= 0 ? 1 : _maximumStartSeconds,
            divisions: _maximumStartSeconds <= 1
                ? null
                : _maximumStartSeconds.floor(),
            label: _format(_start),
            onChanged: _maximumStartSeconds <= 0 || _isPreparing
                ? null
                : (value) async {
                    await _previewPlayer.stop();
                    setState(() => _startSeconds = value);
                  },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Start ${_format(_start)}'),
              Text('End ${_format(_end)}'),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.content_cut_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Clip length: ${_clipDuration.inSeconds} seconds',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _isPreparing ? null : _preview,
            icon: Icon(
              _isPreviewing ? Icons.stop_rounded : Icons.play_arrow_rounded,
            ),
            label: Text(_isPreviewing ? 'Stop preview' : 'Preview selection'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _isPreparing ? null : _createAndSetRingtone,
            icon: _isPreparing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.phone_in_talk_rounded),
            label: Text(
              _isPreparing ? 'Creating ringtone…' : 'Crop and set ringtone',
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 18),
            Text(
              _message!,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
