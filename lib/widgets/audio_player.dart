import 'dart:async';
import 'dart:io';
import 'package:audioplayer/audioplayer.dart';
import 'package:codepan/media/media.dart';
import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/widgets/button.dart';
import 'package:codepan/widgets/loading_indicator.dart';
import 'package:codepan/widgets/media_progress_indicator.dart';
import 'package:flutter/material.dart';

class PanAudioPlayer extends StatefulWidget {
  final OnProgressChanged onProgressChanged;
  final OnCompleted onCompleted;
  final OnError onError;
  final dynamic data;
  final Color color;
  final Color background;

  const PanAudioPlayer({
    Key key,
    this.data,
    this.color,
    this.background = Colors.white,
    this.onProgressChanged,
    this.onCompleted,
    this.onError,
  }) : super(key: key);

  @override
  _PanAudioPlayerState createState() => _PanAudioPlayerState();
}

class _PanAudioPlayerState extends State<PanAudioPlayer> {
  StreamSubscription _onPlayerStateChanged;
  StreamSubscription _onPositionChanged;
  bool _isLoading = false;
  bool _isPlaying = false;
  AudioPlayer _audio;
  double _current = 0;
  double _max = 0;

  dynamic get data => widget.data;

  @override
  void initState() {
    _audio = AudioPlayer();
    _onPositionChanged = _audio.onAudioPositionChanged.listen((time) {
      final value = time.inMilliseconds.roundToDouble();
      _setCurrent(value);
      widget.onProgressChanged?.call(value, _max);
    });
    _onPlayerStateChanged = _audio.onPlayerStateChanged.listen((state) {
      switch (state) {
        case AudioPlayerState.PLAYING:
          setState(() {
            _max = _audio.duration.inMilliseconds.roundToDouble();
          });
          _setPlaying(true);
          _setLoading(false);
          break;
        case AudioPlayerState.PAUSED:
          _setPlaying(false);
          _setLoading(false);
          break;
        case AudioPlayerState.COMPLETED:
          widget.onCompleted?.call();
          _setPlaying(false);
          setState(() {
            _current = _max;
          });
          break;
        case AudioPlayerState.STOPPED:
          _setPlaying(false);
          break;
      }
    }, onError: (msg) {
      widget.onError?.call(Errors.failedToPlayAudio);
      _audio.stop();
      _setLoading(false);
    });
    super.initState();
  }

  @override
  void dispose() {
    _onPositionChanged.cancel();
    _onPlayerStateChanged.cancel();
    _audio.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return Material(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: d.at(50),
            height: d.at(50),
            child: !_isLoading
                ? PanButton(
                    radius: d.at(100),
                    width: d.at(50),
                    height: d.at(50),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: d.at(40),
                      color: PanColors.text,
                    ),
                    onPressed: play,
                  )
                : LoadingIndicator(
                    width: d.at(25),
                    height: d.at(25),
                    color: widget.color,
                  ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: d.at(20),
              ),
              child: MediaProgressIndicator(
                activeColor: widget.color,
                inactiveColor: widget.color.withOpacity(0.3),
                bufferedColor: Colors.black,
                max: _max,
                current: _current,
                barHeight: d.at(4),
                withShadow: false,
                timerColor: PanColors.text,
                onSeekProgress: (milliseconds) async {
                  final seconds = (milliseconds / 1000).roundToDouble();
                  await _audio.seek(seconds);
                  _setCurrent(milliseconds);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> play() async {
    _setLoading(true);
    if (!_isPlaying) {
      if (data is String) {
        await _audio.play(data);
      } else if (data is File) {
        final file = data as File;
        await _audio.play(file.path, isLocal: true);
      } else {
        throw ArgumentError(invalidArgument);
      }
    } else {
      await _audio.pause();
    }
  }

  void _setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _setPlaying(bool isPlaying) {
    setState(() {
      _isPlaying = isPlaying;
    });
  }

  void _setCurrent(double current) {
    setState(() {
      _current = current;
    });
  }
}
