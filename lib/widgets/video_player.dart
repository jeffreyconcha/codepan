import 'package:codepan/media/callback.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/services/navigation.dart';
import 'package:codepan/transitions/route_transition.dart';
import 'package:codepan/widgets/loading_indicator.dart';
import 'package:codepan/widgets/video_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PanVideoPlayer extends StatefulWidget {
  final OnProgressChanged onProgressChanged;
  final OnCompleted onCompleted;
  final bool isFullScreen;
  final Color color;
  final double width;
  final double height;
  final String uri;
  final _PanVideoPlayerState state;

  PanVideoPlayer({
    Key key,
    @required this.uri,
    this.color,
    this.width,
    this.height,
    this.isFullScreen = false,
    this.state,
    this.onProgressChanged,
    this.onCompleted,
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
  double _buffered = 0;
  double _current = 0;
  double _max = 0;

  VideoPlayerValue get _value => _controller?.value;

  bool get _isFullscreen => widget.isFullScreen;

  double get _aspectRatio => _isInitialized ? _value.aspectRatio : 16 / 9;

  @override
  void initState() {
    if (widget.isFullScreen) {
      final state = widget.state;
      _controller = state._controller;
      _isControllerVisible = state._isControllerVisible;
      _isInitialized = state._isInitialized;
      _isLoading = state._isLoading;
      _isPlaying = state._isPlaying;
      _isBuffering = state._isBuffering;
      _current = state._current;
      _buffered = state._buffered;
      _max = state._max;
      if (_isInitialized) {
        _controller.addListener(_listener);
      }
    } else {
      _controller = VideoPlayerController.network(widget.uri);
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller?.removeListener(_listener);
    if (!widget.isFullScreen) {
      _controller?.dispose();
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
    return WillPopScope(
        child: VisibilityDetector(
          key: Key(widget.uri),
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
                    child: _isInitialized
                        ? Stack(
                            children: <Widget>[
                              Center(
                                child: AspectRatio(
                                  aspectRatio: _aspectRatio,
                                  child: VideoPlayer(_controller),
                                ),
                              ),
                              Container(
                                child: _isBuffering
                                    ? LoadingIndicator(
                                        color: widget.color,
                                      )
                                    : null,
                              ),
                            ],
                          )
                        : Container(
                            child: _isLoading
                                ? LoadingIndicator(
                                    color: widget.color,
                                  )
                                : null,
                          ),
                  ),
                  SizedBox(
                    width: width,
                    height: height,
                    child: GestureDetector(
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 250),
                        opacity: _isControllerVisible ? 1 : 0,
                        child: Container(
                          color: Colors.black.withOpacity(0.2),
                          child: _isControllerVisible
                              ? VideoController(
                                  color: widget.color,
                                  isInitialized: _isInitialized,
                                  isLoading: _isLoading,
                                  isFullscreen: _isFullscreen,
                                  isPlaying: _isPlaying,
                                  current: _current,
                                  max: _max,
                                  buffered: _buffered,
                                  onPlay: _onPlay,
                                  onFullScreen: _onFullScreen,
                                  onSeekProgress: _onSeekProgress,
                                )
                              : null,
                        ),
                      ),
                      onTap: () {
                        _setControllerVisible(!_isControllerVisible);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onWillPop: () async {
          if (_isFullscreen) {
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            _orientationChanged = true;
          }
          return true;
        });
  }

  Future<void> initializeVideo() async {
    if (!_isInitialized) {
      _setLoading(true);
      _setControllerVisible(false);
      await _controller.initialize();
      _controller.addListener(_listener);
      setState(() {
        _max = _value.duration.inMilliseconds.toDouble();
        _isInitialized = true;
      });
      _setLoading(false);
    }
  }

  void _onPlay() async {
    await initializeVideo();
    if (_current == _max) {
      await _onSeekProgress(1);
    }
    if (_value.isPlaying) {
      await _controller.pause();
    } else {
      _setLoading(true);
      await _controller.play();
      _setLoading(false);
    }
    _setPlaying(_value.isPlaying);
  }

  void _listener() async {
    double value = _value.position.inMilliseconds.toDouble();
    if (value != _current) {
      _setCurrent(value);
      widget.onProgressChanged?.call(value, _max);
    }
    if (value == _max) {
      _setPlaying(false);
      widget.onCompleted?.call();
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
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      NavigationService().push(FadeRoute(
        enter: PanVideoPlayer(
          uri: widget.uri,
          color: widget.color,
          isFullScreen: !_isFullscreen,
          state: this,
        ),
      ));
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      NavigationService().pop();
    }
    _orientationChanged = true;
  }
}
