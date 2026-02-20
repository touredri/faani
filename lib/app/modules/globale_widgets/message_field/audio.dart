import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart' as ap;

class AudioPlayer extends StatefulWidget {
  const AudioPlayer({
    required this.source,
    super.key,
  });

  final String source;

  @override
  _AudioPlayer createState() => _AudioPlayer();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<String>('source', source));
  }
}

class _AudioPlayer extends State<AudioPlayer> {
  static const double _controlSize = 30.0;

  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  late StreamSubscription<ap.PlayerState> _playerStateChangedSubscription;
  late StreamSubscription<Duration?> _durationChangedSubscription;
  late StreamSubscription<Duration> _positionChangedSubscription;
  bool _fromCache = false;

  @override
  void initState() {
    _playerStateChangedSubscription =
        _audioPlayer.playerStateStream.listen((ap.PlayerState state) async {
      if (state.processingState == ap.ProcessingState.completed) {
        await stop();
      }
      setState(() {});
    });
    _positionChangedSubscription = _audioPlayer.positionStream
        .listen((Duration position) => setState(() {}));
    _durationChangedSubscription = _audioPlayer.durationStream
        .listen((Duration? duration) => setState(() {}));
    _init();

    super.initState();
  }

  ap.AudioSource _getAudioSource() {
    return ap.LockCachingAudioSource(Uri.parse(widget.source));
  }

  Future<void> _init() async {
    final audioSource = _getAudioSource();
    await _audioPlayer.setAudioSource(audioSource);
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _positionChangedSubscription.cancel();
    _durationChangedSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildControl(),
            _buildSlider(constraints.maxWidth),
          ],
        );
      },
    );
  }

  Widget _buildControl() {
    Icon icon;
    Color color;

    if (_audioPlayer.playerState.playing) {
      icon = const Icon(Icons.pause, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final ThemeData theme = Theme.of(context);
      icon = Icon(Icons.play_arrow,
          color: (_fromCache ? Colors.green : theme.primaryColor), size: 30);
      color = (_fromCache ? Colors.green : Theme.of(context).primaryColor)
          .withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child:
              SizedBox(width: _controlSize, height: _controlSize, child: icon),
          onTap: () {
            if (_audioPlayer.playerState.playing) {
              pause();
            } else {
              play();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSlider(double widgetWidth) {
    final Duration position = _audioPlayer.position;
    final Duration? duration = _audioPlayer.duration;
    bool canSetValue = false;
    if (duration != null) {
      canSetValue = position.inMilliseconds > 0;
      canSetValue &= position.inMilliseconds < duration.inMilliseconds;
    }
    final width = (widgetWidth - _controlSize).clamp(120.0, double.infinity);
    String playerTxt = '00:00';
    if (duration != null) {
      playerTxt = DateFormat('mm:ss', 'en_US')
          .format(DateTime.fromMillisecondsSinceEpoch(duration.inMilliseconds));
    }

    return SizedBox(
      width: width,
      child: Row(
        children: [
          Expanded(
            child: Slider(
              activeColor:
                  _fromCache ? Colors.green : Theme.of(context).primaryColor,
              inactiveColor: (_fromCache
                  ? Colors.green
                  : Theme.of(context).colorScheme.secondary),
              onChanged: (double v) {
                if (duration != null) {
                  final double position = v * duration.inMilliseconds;
                  _audioPlayer.seek(Duration(milliseconds: position.round()));
                }
              },
              value: canSetValue && duration != null
                  ? position.inMilliseconds / duration.inMilliseconds
                  : 0.0,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            playerTxt,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> play() {
    return _audioPlayer.play();
  }

  Future<void> pause() {
    return _audioPlayer.pause();
  }

  Future<void> stop() async {
    // await _updatePlayed();
    _fromCache = true;
    await _audioPlayer.stop();
    setState(() {});
    return _audioPlayer.seek(Duration.zero);
  }
}
