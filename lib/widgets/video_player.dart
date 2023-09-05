import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:codepan/extensions/extensions.dart';
import 'package:codepan/media/media.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/transitions/route_transition.dart';
import 'package:codepan/utils/debouncer.dart';
import 'package:codepan/utils/motin_detector.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/loading_indicator.dart';
import 'package:codepan/widgets/video_controller.dart';
import 'package:codepan/widgets/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subtitle_wrapper_package/data/data.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

typedef OnSaveState = void Function(
  _PanVideoPlayerState state,
);

const int delay = 5000;

class PanVideoPlayer extends StatefulWidget {
  final OnProgressChanged? onProgressChanged;
  final ValueChanged<bool>? onFullscreenChanged;
  final Widget? thumbnailErrorWidget;
  final Color? color, playButtonColor;
  final OnCompleted? onCompleted;
  final bool isFullScreen, autoFullScreen;
  final double? width;
  final double? height;
  final dynamic data;
  final _PanVideoPlayerState? state;
  final OnSaveState? onSaveState;
  final OnError? onError;
  final bool showBuffer;
  final String? thumbnailUrl, subtitleUrl;
  final File? subtitle;

  PanVideoPlayer({
    super.key,
    required this.data,
    this.color,
    this.playButtonColor,
    this.width,
    this.height,
    this.state,
    this.onProgressChanged,
    this.onFullscreenChanged,
    this.onCompleted,
    this.onSaveState,
    this.onError,
    this.isFullScreen = false,
    this.autoFullScreen = false,
    this.showBuffer = true,
    this.thumbnailUrl,
    this.thumbnailErrorWidget,
    this.subtitleUrl,
    this.subtitle,
  });

  @override
  _PanVideoPlayerState createState() => _PanVideoPlayerState();
}

class _PanVideoPlayerState extends State<PanVideoPlayer> {
  late final MotionDetector _detector;
  VideoPlayerController? _videoController;
  SubtitleController? _subController;
  bool _orientationChanged = false;
  bool _isControllerVisible = true;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isCompleted = false;
  Debouncer? _debouncer;
  double _buffered = 0;
  double _current = 0;
  double _max = 0;

  VideoPlayerValue? get value => _videoController?.value;

  bool get isFullscreen => widget.isFullScreen;

  double get aspectRatio => _isInitialized ? value!.aspectRatio : 16 / 9;

  dynamic get data => widget.data;

  bool get showBuffer => widget.showBuffer;

  String? get thumbnailUrl => widget.thumbnailUrl;

  String? get key {
    if (data is String) {
      return data;
    } else if (data is File) {
      return (data as File).path;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (isFullscreen) {
      _onSaveState(widget.state!);
      widget.onFullscreenChanged?.call(true);
    } else {
      if (data is String) {
        _videoController = VideoPlayerController.network(data);
      } else if (data is File) {
        _videoController = VideoPlayerController.file(data);
      } else {
        throw ArgumentError(invalidArgument);
      }
      _debouncer = Debouncer(milliseconds: delay);
    }
    _detector = MotionDetector(
      onOrientationChanged: (orientation) {
        if (_isPlaying) {
          switch (orientation) {
            case DeviceOrientation.landscapeLeft:
            case DeviceOrientation.landscapeRight:
              if (!isFullscreen) {
                _enterFullScreen(orientation);
              }
              break;
            case DeviceOrientation.portraitUp:
              if (isFullscreen) {
                _exitFullScreen();
                context.pop();
              }
              break;
            default:
              break;
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _videoController?.removeListener(_listener);
    if (!isFullscreen) {
      _videoController?.dispose();
    }
    if (widget.onSaveState != null) {
      widget.onSaveState!(this);
    }
    _debouncer?.cancel();
    _detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final width = widget.width ?? d.maxWidth;
    final height =
        isFullscreen ? d.maxHeight : widget.height ?? d.maxWidth / aspectRatio;
    return VisibilityDetector(
      key: Key(key!),
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
                child: IfElseBuilder(
                  condition: _isInitialized,
                  ifBuilder: (context) {
                    return Stack(
                      children: <Widget>[
                        Center(
                          child: AspectRatio(
                            aspectRatio: aspectRatio,
                            child: WrapperBuilder(
                              condition: widget.subtitle != null ||
                                  widget.subtitleUrl != null,
                              child: VideoPlayer(_videoController!),
                              builder: (context, child) {
                                return SubtitleWrapper(
                                  subtitleController: _subController!,
                                  videoPlayerController: _videoController!,
                                  subtitleStyle: SubtitleStyle(
                                    textColor: Colors.white,
                                    fontSize:
                                        isFullscreen ? d.at(17) : d.at(12),
                                    hasBorder: true,
                                    borderStyle: SubtitleBorderStyle(
                                      color: Colors.black,
                                      strokeWidth: d.at(2),
                                    ),
                                  ),
                                  videoChild: child,
                                );
                              },
                            ),
                          ),
                        ),
                        IfElseBuilder(
                          condition: _isBuffering,
                          ifBuilder: (context) {
                            return LoadingIndicator(
                              color: widget.color,
                            );
                          },
                        ),
                      ],
                    );
                  },
                  elseBuilder: (context) {
                    return Stack(
                      children: [
                        CachedNetworkImage(
                          width: width,
                          height: height,
                          imageUrl: thumbnailUrl ?? '',
                          fit: BoxFit.contain,
                          errorWidget: (context, url, error) {
                            return widget.thumbnailErrorWidget ??
                                Container(color: Colors.black);
                          },
                        ),
                        IfElseBuilder(
                          condition: _isLoading,
                          ifBuilder: (context) {
                            return LoadingIndicator(
                              color: widget.color,
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                width: width,
                height: height,
                child: GestureDetector(
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 250),
                    opacity: _isControllerVisible ? 1 : 0,
                    child: IfElseBuilder(
                      color: Colors.black.withOpacity(0.2),
                      condition: _isControllerVisible,
                      ifBuilder: (context) {
                        return VideoController(
                          color: widget.color,
                          playButtonColor: widget.playButtonColor,
                          isInitialized: _isInitialized,
                          isLoading: _isLoading,
                          isFullscreen: isFullscreen,
                          isPlaying: _isPlaying,
                          current: _current,
                          max: _max,
                          buffered: showBuffer ? _buffered : 0,
                          onPlay: _onPlay,
                          onFullScreen: _onFullScreen,
                          onSeekProgress: _onSeekProgress,
                        );
                      },
                    ),
                  ),
                  onTap: () {
                    _setControllerVisible(!_isControllerVisible);
                    if (_isControllerVisible) {
                      _autoHideController();
                    } else {
                      _debouncer?.cancel();
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
        await _initializeSubtitle();
        await _videoController!.initialize();
        _videoController!.addListener(_listener);
        setState(() {
          _max = value!.duration.inMilliseconds.toDouble();
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

  Future<void> _initializeSubtitle() async {
    final file = widget.subtitle;
    final url = widget.subtitleUrl;
    if (file != null) {
      final content = await file.readAsString();
      _subController = SubtitleController(
        subtitleDecoder: SubtitleDecoder.utf8,
        showSubtitles: true,
        subtitlesContent: content,
      );
    } else if (url != null) {
      _subController = SubtitleController(
        subtitleDecoder: SubtitleDecoder.utf8,
        showSubtitles: true,
        subtitleUrl: url,
      );
    }
  }

  void _onPlay() async {
    await initializeVideo();
    if (_isInitialized) {
      if (_current == _max) {
        await _onSeekProgress(1);
      }
      if (value!.isPlaying) {
        await _videoController!.pause();
      } else {
        _setLoading(true);
        await _videoController!.play();
        _setLoading(false);
        _isCompleted = false;
      }
      _setPlaying(value!.isPlaying);
      if (value!.isPlaying) {
        _autoHideController();
      } else {
        _debouncer?.cancel();
      }
    }
  }

  void _listener() async {
    final player = value;
    if (player != null) {
      double milliseconds = player.position.inMilliseconds.toDouble();
      if (milliseconds != _current) {
        _setCurrent(milliseconds);
        widget.onProgressChanged?.call(milliseconds, _max);
      }
      if (milliseconds == _max) {
        _setPlaying(false);
        if (!_isCompleted) {
          widget.onCompleted?.call();
          _isCompleted = true;
        }
      }
      if (_isPlaying != player.isPlaying) {
        _setPlaying(player.isPlaying);
      }
      _updateBuffered();
    }
  }

  Future<void> _onSeekProgress(double input) async {
    final milliseconds = input < 0.0 ? 0.0 : (input > _max ? _max : input);
    _setLoading(true);
    await _videoController!.seekTo(
      Duration(
        milliseconds: milliseconds.toInt(),
      ),
    );
    _setCurrent(milliseconds);
    _setLoading(false);
    _autoHideController();
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
    final range = value!.buffered;
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
    _debouncer?.cancel();
    if (!isFullscreen) {
      _enterFullScreen();
    } else {
      _exitFullScreen();
      context.pop();
    }
    _autoHideController();
  }

  void _enterFullScreen([
    DeviceOrientation? orientation,
  ]) async {
    if (orientation != null) {
      await SystemChrome.setPreferredOrientations([orientation]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    _orientationChanged = true;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    context.fadeIn(
      page: WillPopScope(
        child: PanVideoPlayer(
          data: widget.data,
          color: widget.color,
          isFullScreen: true,
          onSaveState: _onSaveState,
          onFullscreenChanged: widget.onFullscreenChanged,
          autoFullScreen: widget.autoFullScreen,
          thumbnailUrl: thumbnailUrl,
          subtitleUrl: widget.subtitleUrl,
          subtitle: widget.subtitle,
          state: this,
        ),
        onWillPop: () async {
          _exitFullScreen();
          return true;
        },
      ),
      onExit: (value) {
        widget.onFullscreenChanged?.call(false);
      },
    );
  }

  void _exitFullScreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _orientationChanged = true;
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    if (widget.onSaveState != null) {
      widget.onSaveState!(this);
    }
  }

  void _onSaveState(_PanVideoPlayerState state) {
    _videoController = state._videoController;
    _subController = state._subController;
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
      _videoController!.addListener(_listener);
    }
  }

  void _autoHideController() {
    _debouncer?.run(() {
      _setControllerVisible(false);
    });
  }
}
