import 'dart:io';
import 'package:codepan/media/media.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/transitions/route_transition.dart';
import 'package:codepan/utils/debouncer.dart';
import 'package:codepan/widgets/loading_indicator.dart';
import 'package:codepan/widgets/placeholder_handler.dart';
import 'package:codepan/widgets/video_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

typedef OnSaveState = void Function(
  _PanVideoPlayerState state,
);

const int delay = 5000;

class PanVideoPlayer extends StatefulWidget {
  final OnProgressChanged onProgressChanged;
  final OnCompleted onCompleted;
  final bool isFullScreen;
  final Color color;
  final double width;
  final double height;
  final dynamic data;
  final _PanVideoPlayerState state;
  final OnSaveState onSaveState;
  final OnError onError;
  final bool showBuffer;

  PanVideoPlayer({
    Key key,
    @required this.data,
    this.color,
    this.width,
    this.height,
    this.state,
    this.onProgressChanged,
    this.onCompleted,
    this.onSaveState,
    this.onError,
    this.isFullScreen = false,
    this.showBuffer = true,
  }) : super(key: key);

  @override
  _PanVideoPlayerState createState() => _PanVideoPlayerState();
}

class _PanVideoPlayerState extends State<PanVideoPlayer> {
  VideoPlayerController _controller;
  bool _orientationChanged = false;
  bool _isControllerVisible = true;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isCompleted = false;
  Debouncer _debouncer;
  double _buffered = 0;
  double _current = 0;
  double _max = 0;

  VideoPlayerValue get _value => _controller?.value;

  bool get _isFullscreen => widget.isFullScreen;

  double get _aspectRatio => _isInitialized ? _value.aspectRatio : 16 / 9;

  dynamic get data => widget.data;

  bool get showBuffer => widget.showBuffer;

  String get key {
    if (data is String) {
      return data;
    } else if (data is File) {
      return (data as File).path;
    }
    return null;
  }

  @override
  void initState() {
    if (widget.isFullScreen) {
      _onSaveState(widget.state);
    } else {
      if (data is String) {
        _controller = VideoPlayerController.network(data);
      } else if (data is File) {
        _controller = VideoPlayerController.file(data);
      } else {
        throw ArgumentError(invalidArgument);
      }
      _debouncer = Debouncer(milliseconds: delay);
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller?.removeListener(_listener);
    if (!widget.isFullScreen) {
      _controller?.dispose();
    }
    if (widget.onSaveState != null) {
      widget.onSaveState(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final width = widget.width ?? d.maxWidth;
    final height = _isFullscreen
        ? d.maxHeight
        : widget.height ?? d.maxWidth / _aspectRatio;
    return VisibilityDetector(
      key: Key(key),
      onVisibilityChanged: (info) {
        if (_isInitialized &&
            _isPlaying &&
            !_orientationChanged &&
            info.visibleFraction == 0.0) {
          _onPlay();
        }
        _orientationChanged = false;
      },
      child: Material(
        color: Colors.grey.shade900,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: <Widget>[
              Center(
                child: PlaceholderHandler(
                  condition: _isInitialized,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: AspectRatio(
                          aspectRatio: _aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                      PlaceholderHandler(
                        condition: _isBuffering,
                        child: LoadingIndicator(
                          color: widget.color,
                        ),
                      ),
                    ],
                  ),
                  placeholder: PlaceholderHandler(
                    condition: _isLoading,
                    child: LoadingIndicator(
                      color: widget.color,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: width,
                height: height,
                child: GestureDetector(
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 250),
                    opacity: _isControllerVisible ? 1 : 0,
                    child: PlaceholderHandler(
                      color: Colors.black.withOpacity(0.2),
                      condition: _isControllerVisible,
                      child: VideoController(
                        color: widget.color,
                        isInitialized: _isInitialized,
                        isLoading: _isLoading,
                        isFullscreen: _isFullscreen,
                        isPlaying: _isPlaying,
                        current: _current,
                        max: _max,
                        buffered: showBuffer ? _buffered : 0,
                        onPlay: _onPlay,
                        onFullScreen: _onFullScreen,
                        onSeekProgress: _onSeekProgress,
                      ),
                    ),
                  ),
                  onTap: () {
                    _setControllerVisible(!_isControllerVisible);
                    if (_isControllerVisible) {
                      _debouncer.run(() {
                        _setControllerVisible(false);
                      });
                    } else {
                      _debouncer.cancel();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initializeVideo() async {
    if (!_isInitialized) {
      try {
        _setLoading(true);
        _setControllerVisible(false);
        await Future.delayed(Duration(milliseconds: 500));
        await _controller.initialize();
        _controller.addListener(_listener);
        setState(() {
          _max = _value.duration.inMilliseconds.toDouble();
          _isInitialized = true;
        });
        _setLoading(false);
      } catch (error) {
        widget.onError?.call(Errors.failedToPlayVideo);
        _setLoading(false);
        _setControllerVisible(true);
        rethrow;
      }
    }
  }

  void _onPlay() async {
    await initializeVideo();
    if (_isInitialized) {
      if (_current == _max) {
        await _onSeekProgress(1);
      }
      if (_value.isPlaying) {
        await _controller.pause();
      } else {
        _setLoading(true);
        await _controller.play();
        _setLoading(false);
        _isCompleted = false;
      }
      _setPlaying(_value.isPlaying);
    }
  }

  void _listener() async {
    double value = _value.position.inMilliseconds.toDouble();
    if (value != _current) {
      _setCurrent(value);
      widget.onProgressChanged?.call(value, _max);
    }
    if (value == _max) {
      _setPlaying(false);
      if (!_isCompleted) {
        widget.onCompleted?.call();
        _isCompleted = true;
      }
    }
    _updateBuffered();
  }

  Future<void> _onSeekProgress(double input) async {
    final milliseconds = input < 0.0 ? 0.0 : (input > _max ? _max : input);
    _setLoading(true);
    await _controller.seekTo(
      Duration(
        milliseconds: milliseconds.toInt(),
      ),
    );
    _setCurrent(milliseconds);
    _setLoading(false);
  }

  void _setCurrent(double current) {
    setState(() {
      _current = current;
    });
  }

  void _updateBuffered() {
    setState(() {
      _buffered = _getBuffered();
    });
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

  void _setControllerVisible(isControllerVisible) {
    setState(() {
      _isControllerVisible = isControllerVisible;
    });
  }

  double _getBuffered() {
    final range = _value.buffered;
    if (range.length > 0) {
      final iterable = range.map((element) {
        final start = element.start.inMilliseconds;
        final end = element.end.inMilliseconds;
        return end - start;
      });
      final list = iterable.toList();
      final buffered = list.reduce((value, element) => value + element);
      return buffered / _max;
    }
    return 0;
  }

  void _onFullScreen() async {
    if (!_isFullscreen) {
      _enterFullScreen();
    } else {
      _exitFullScreen();
      Navigator.of(context).pop();
    }
  }

  void _enterFullScreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIOverlays([]);
    Navigator.of(context).push(
      FadeRoute(
        enter: WillPopScope(
          child: PanVideoPlayer(
            data: widget.data,
            color: widget.color,
            isFullScreen: !_isFullscreen,
            state: this,
            onSaveState: !_isInitialized ? _onSaveState : null,
          ),
          onWillPop: () async {
            _exitFullScreen();
            return true;
          },
        ),
      ),
    );
    _orientationChanged = true;
  }

  void _exitFullScreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIOverlays(
      SystemUiOverlay.values,
    );
    _orientationChanged = true;
  }

  void _onSaveState(_PanVideoPlayerState state) {
    _controller = state._controller;
    _isControllerVisible = state._isControllerVisible;
    _isInitialized = state._isInitialized;
    _isLoading = state._isLoading;
    _isPlaying = state._isPlaying;
    _isBuffering = state._isBuffering;
    _current = state._current;
    _buffered = state._buffered;
    _debouncer = state._debouncer;
    _max = state._max;
    if (_isInitialized) {
      _controller.addListener(_listener);
    }
  }
}
