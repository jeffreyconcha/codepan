import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:codepan/media/media.dart';
import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/widgets/button.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/loading_indicator.dart';
import 'package:codepan/widgets/media_progress_indicator.dart';
import 'package:flutter/material.dart';

class PanAudioPlayer extends StatefulWidget {
  final Color? progressBarColor;
  final Color playButtonColor;
  final OnProgressChanged? onProgressChanged;
  final OnCompleted? onCompleted;
  final String? loadingIcon;
  final Color background;
  final OnError? onError;
  final dynamic data;

  const PanAudioPlayer({
    super.key,
    this.background = Colors.white,
    this.progressBarColor,
    this.playButtonColor = PanColors.text,
    this.data,
    this.onCompleted,
    this.onError,
    this.onProgressChanged,
    this.loadingIcon,
  });

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
    _onPositionChanged = _audio.onPositionChanged.listen((time) {
      final value = time.inMilliseconds.roundToDouble();
      _setCurrent(value);
      widget.onProgressChanged?.call(value, _max);
    });
    _onPlayerStateChanged = _audio.onPlayerStateChanged.listen((state) async {
      switch (state) {
        case PlayerState.playing:
          final duration = await _audio.getDuration();
          setState(() {
            _max = duration?.inMilliseconds.toDouble() ?? 0;
          });
          _setPlaying(true);
          _setLoading(false);
          break;
        case PlayerState.paused:
          _setPlaying(false);
          _setLoading(false);
          break;
        case PlayerState.completed:
          widget.onCompleted?.call();
          _setPlaying(false);
          setState(() {
            _current = _max;
          });
          break;
        case PlayerState.stopped:
          _setPlaying(false);
          break;
        default:
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
    final t = Theme.of(context);
    final progressBarColor = widget.progressBarColor ?? t.primaryColor;
    return Material(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IfElseBuilder(
            width: d.at(40),
            height: d.at(40),
            condition: !_isLoading,
            margin: EdgeInsets.only(
              right: d.at(5),
            ),
            ifBuilder: (context) {
              return PanButton(
                radius: d.at(80),
                width: d.at(40),
                height: d.at(40),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: d.at(30),
                  color: widget.playButtonColor,
                ),
                onTap: play,
              );
            },
            elseBuilder: (context) {
              return LoadingIndicator(
                icon: widget.loadingIcon,
                radius: d.at(12),
                color: progressBarColor,
              );
            },
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: d.at(20),
              ),
              child: MediaProgressIndicator(
                activeColor: progressBarColor,
                inactiveColor: progressBarColor.withOpacity(0.3),
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
        final source = UrlSource(data);
        await _audio.play(source);
      } else if (data is File) {
        final file = data as File;
        final source = BytesSource(await file.readAsBytes());
        await _audio.play(source);
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
