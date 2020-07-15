import 'dart:async';
import 'package:audioplayer/audioplayer.dart';
import 'package:codepan/media/callback.dart';
import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/widgets/button.dart';
import 'package:codepan/widgets/loading_indicator.dart';
import 'package:codepan/widgets/media_progress_indicator.dart';
import 'package:flutter/material.dart';

class PanAudioPlayer extends StatefulWidget {
  final OnProgressChanged onProgressChanged;
  final OnCompleted onCompleted;
  final String uri;
  final Color color;
  final Color background;

  const PanAudioPlayer({
    Key key,
    this.uri,
    this.color,
    this.background = Colors.white,
    this.onProgressChanged,
    this.onCompleted,
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

  @override
  void initState() {
    _audio = AudioPlayer();
    _onPositionChanged = _audio.onAudioPositionChanged.listen((time) {
      final value = time.inMilliseconds.toDouble();
      _setCurrent(value);
      widget.onProgressChanged?.call(value, _max);
    });
    _onPlayerStateChanged = _audio.onPlayerStateChanged.listen((state) {
      switch (state) {
        case AudioPlayerState.PLAYING:
          setState(() {
            _max = _audio.duration.inMilliseconds.toDouble();
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
          break;
        case AudioPlayerState.STOPPED:
          break;
      }
    }, onError: (msg) {});
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
                  final seconds = (milliseconds / 1000).toDouble();
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
      await _audio.play(widget.uri);
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
