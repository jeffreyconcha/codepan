import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:codepan/media/media.dart';
import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/widgets/button.dart';
import 'package:codepan/widgets/loading_indicator.dart';
import 'package:codepan/widgets/media_progress_indicator.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:flutter/material.dart';

class PanAudioPlayer extends StatefulWidget {
  final OnProgressChanged? onProgressChanged;
  final OnCompleted? onCompleted;
  final Color background;
  final OnError? onError;
  final dynamic data;
  final Color? color;

  const PanAudioPlayer({
    Key? key,
    this.background = Colors.white,
    this.color,
    this.data,
    this.onCompleted,
    this.onError,
    this.onProgressChanged,
  }) : super(key: key);

  @override
  _PanAudioPlayerState createState() => _PanAudioPlayerState();
}

class _PanAudioPlayerState extends State<PanAudioPlayer> {
  late StreamSubscription _onPlayerStateChanged;
  late StreamSubscription _onPositionChanged;
  bool _isLoading = false;
  bool _isPlaying = false;
  late AudioPlayer _audio;
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
        case PlayerState.PLAYING:
          setState(() async {
            _max = (await _audio.getDuration()).toDouble();
          });
          _setPlaying(true);
          _setLoading(false);
          break;
        case PlayerState.PAUSED:
          _setPlaying(false);
          _setLoading(false);
          break;
        case PlayerState.COMPLETED:
          widget.onCompleted?.call();
          _setPlaying(false);
          setState(() {
            _current = _max;
          });
          break;
        case PlayerState.STOPPED:
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
          IfElseBuilder(
            width: d.at(50),
            height: d.at(50),
            condition: !_isLoading,
            ifBuilder: (context) {
              return PanButton(
                radius: d.at(100),
                width: d.at(50),
                height: d.at(50),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: d.at(40),
                  color: PanColors.text,
                ),
                onPressed: play,
              );
            },
            elseBuilder: (context) {
              return LoadingIndicator(
                width: d.at(25),
                height: d.at(25),
                color: widget.color,
              );
            },
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: d.at(20),
              ),
              child: MediaProgressIndicator(
                activeColor: widget.color,
                inactiveColor: widget.color!.withOpacity(0.3),
                bufferedColor: Colors.transparent,
                max: _max,
                current: _current,
                barHeight: d.at(4),
                withShadow: false,
                timerColor: PanColors.text,
                onSeekProgress: (milliseconds) async {
                  final position = Duration(milliseconds: milliseconds.toInt());
                  await _audio.seek(position);
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
