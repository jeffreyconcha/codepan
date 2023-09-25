import 'dart:io';
import 'package:codepan/widgets/text.dart';
import 'package:http/http.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:codepan/extensions/extensions.dart';
import 'package:codepan/media/media.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/utils/debouncer.dart';
import 'package:codepan/utils/motin_detector.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/loading_indicator.dart';
import 'package:codepan/widgets/video_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

typedef OnSaveState = void Function(
  _PanVideoPlayerState state,
);

typedef SubtitleTextBuilder = Widget Function(
  BuildContext context,
  String text,
);

const int delay = 5000;

class PanVideoPlayer extends StatefulWidget {
  final OnProgressChanged? onProgressChanged;
  final ValueChanged<bool>? onFullscreenChanged;
  final Widget? thumbnailErrorWidget;
  final Color? color, playButtonColor;
  final OnCompleted? onCompleted;
  final VoidCallback? onPlay, onPause, onInitialized, onTapSubtitle;
  final WidgetBuilder? subtitleButtonBuilder;
  final SubtitleTextBuilder? subtitleTextBuilder;
  final bool isFullScreen, autoFullScreen;
  final SubtitleController? subtitleController;
  final double? width, height;
  final Duration? start;
  final dynamic data;
  final _PanVideoPlayerState? state;
  final OnSaveState? onSaveState;
  final OnError? onError;
  final bool showBuffer;
  final String? thumbnailUrl;

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
    this.onTapSubtitle,
    this.isFullScreen = false,
    this.autoFullScreen = false,
    this.showBuffer = true,
    this.thumbnailUrl,
    this.thumbnailErrorWidget,
    this.subtitleController,
    this.onPlay,
    this.onPause,
    this.onInitialized,
    this.start,
    this.subtitleButtonBuilder,
    this.subtitleTextBuilder,
  });

  @override
  _PanVideoPlayerState createState() => _PanVideoPlayerState();
}

class _PanVideoPlayerState extends State<PanVideoPlayer> {
  MotionDetector? _detector;
  VideoPlayerController? _videoController;
  bool _isControllerVisible = true;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isCompleted = false;
  bool _isManualFullScreen = false;
  bool _isAutoFullScreen = false;
  Debouncer? _debouncer;
  double _buffered = 0;
  double _current = 0;
  double _max = 0;

  SubtitleController? get subController => widget.subtitleController;

  VideoPlayerValue? get value => _videoController?.value;

  bool get isFullScreen => widget.isFullScreen;

  double get aspectRatio => _isInitialized ? value!.aspectRatio : 16 / 9;

  dynamic get data => widget.data;

  bool get showBuffer => widget.showBuffer;

  bool get isNormalView {
    return !isFullScreen && !_isManualFullScreen && !_isAutoFullScreen;
  }

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
    if (isFullScreen) {
      _onSaveState(widget.state!);
      widget.onFullscreenChanged?.call(true);
    } else {
      _debouncer = Debouncer(milliseconds: delay);
      _detector = MotionDetector(
        onOrientationChanged: (orientation) {
          if ((value?.isPlaying ?? false) && !_isManualFullScreen) {
            switch (orientation) {
              case DeviceOrientation.landscapeLeft:
              case DeviceOrientation.landscapeRight:
                if (!_isAutoFullScreen) {
                  _enterFullScreen(orientation);
                  _isAutoFullScreen = true;
                }
                break;
              case DeviceOrientation.portraitUp:
                if (_isAutoFullScreen) {
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
    subController?.addListener(() {
      if (_isInitialized) {
        final controller = subController!;
        if (!controller.isOff) {
          final subtitleData = controller.data;
          final subtitleType = controller.type;
          final closedCaptionFile = _loadSubtitle(
            subtitleData,
            subtitleType,
          );
          _videoController!.setClosedCaptionFile(closedCaptionFile);
        } else {
          _videoController!.setClosedCaptionFile(null);
        }
      }
    });
  }

  @override
  void dispose() {
    _videoController?.removeListener(_listener);
    if (!isFullScreen) {
      _videoController?.dispose();
    }
    if (widget.onSaveState != null) {
      widget.onSaveState!(this);
    }
    _debouncer?.cancel();
    _detector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final width = widget.width ?? d.maxWidth;
    final height =
        isFullScreen ? d.maxHeight : widget.height ?? d.maxWidth / aspectRatio;
    return VisibilityDetector(
      key: Key(key!),
      onVisibilityChanged: (info) {
        if (_isInitialized &&
            _isPlaying &&
            isNormalView &&
            info.visibleFraction == 0.0) {
          _onTapPlay();
          debugPrint('Auto pause video.');
        }
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
                            child: VideoPlayer(_videoController!),
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
              IfElseBuilder(
                condition: _isInitialized,
                ifBuilder: (context) {
                  final text = _videoController!.value.caption.text;
                  return widget.subtitleTextBuilder?.call(context, text) ??
                      PanText(
                        text: text,
                        fontColor: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: isFullScreen ? d.at(17) : d.at(12),
                        alignment: Alignment.bottomCenter,
                        textAlign: TextAlign.center,
                        margin: EdgeInsets.only(
                          bottom: d.at(10),
                        ),
                        shadows: [
                          Shadow(
                            offset: Offset(d.at(1), d.at(1)),
                            blurRadius: d.at(3),
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      );
                },
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
                          withSubtitle: subController != null,
                          subtitleButtonBuilder: widget.subtitleButtonBuilder,
                          playButtonColor: widget.playButtonColor,
                          isInitialized: _isInitialized,
                          isLoading: _isLoading,
                          isFullscreen: isFullScreen,
                          isPlaying: _isPlaying,
                          current: _current,
                          max: _max,
                          buffered: showBuffer ? _buffered : 0,
                          onTapPlay: _onTapPlay,
                          onTapFullScreen: _onTapFullScreen,
                          onSeekProgress: _onSeekProgress,
                          onTapSubtitle: widget.onTapSubtitle,
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
        final subtitleData = subController?.data;
        final subtitleType = subController?.type;
        final closedCaptionFile = subtitleData != null && subtitleType != null
            ? _loadSubtitle(subtitleData, subtitleType)
            : null;
        if (data is String) {
          _videoController = VideoPlayerController.network(
            data,
            closedCaptionFile: closedCaptionFile,
          );
        } else if (data is File) {
          _videoController = VideoPlayerController.file(
            data,
            closedCaptionFile: closedCaptionFile,
          );
        } else {
          throw ArgumentError(invalidArgument);
        }
        await Future.delayed(Duration(milliseconds: 500));
        await _videoController!.initialize();
        _videoController!.addListener(_listener);
        setState(() {
          _max = value!.duration.inMilliseconds.toDouble();
          _isInitialized = true;
          widget.onInitialized?.call();
        });
        final start = widget.start;
        if (start != null) {
          final milliseconds = start.inMilliseconds.toDouble();
          if (milliseconds < _max) {
            _onSeekProgress(start.inMilliseconds.toDouble());
          }
        }
        _setLoading(false);
      } catch (error) {
        widget.onError?.call(Errors.failedToPlayVideo);
        _setLoading(false);
        _setControllerVisible(true);
        rethrow;
      }
    }
  }

  Future<ClosedCaptionFile> _loadSubtitle(
    dynamic data,
    SubtitleType type,
  ) async {
    String? content;
    if (data is String) {
      final client = Client();
      final response = await client.get(Uri.parse(data));
      content = response.body;
    } else if (data is File) {
      content = await data.readAsString();
    }
    if (content?.isNotEmpty ?? false) {
      return type == SubtitleType.srt
          ? SubRipCaptionFile(content!)
          : WebVTTCaptionFile(content!);
    }
    throw ArgumentError(invalidArgument);
  }

  void _onTapPlay() async {
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
        if (player.isPlaying) {
          widget.onPlay?.call();
        } else {
          widget.onPause?.call();
        }
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
      if (isPlaying) {
        _isLoading = false;
      }
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

  void _onTapFullScreen() async {
    _debouncer?.cancel();
    if (!isFullScreen) {
      _enterFullScreen();
      _isManualFullScreen = true;
    } else {
      context.pop();
    }
    _autoHideController();
  }

  Future<void> _enterFullScreen([
    DeviceOrientation orientation = DeviceOrientation.landscapeLeft,
  ]) async {
    //Orientation in iOS is inverted.
    if (Platform.isIOS) {
      switch (orientation) {
        case DeviceOrientation.landscapeLeft:
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeRight,
          ]);
          break;
        case DeviceOrientation.landscapeRight:
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
          ]);
          break;
        default:
          break;
      }
    } else {
      await SystemChrome.setPreferredOrientations([orientation]);
    }
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    context.fadeIn(
      page: PanVideoPlayer(
        data: widget.data,
        color: widget.color,
        isFullScreen: true,
        onSaveState: _onSaveState,
        onFullscreenChanged: widget.onFullscreenChanged,
        autoFullScreen: widget.autoFullScreen,
        thumbnailUrl: widget.thumbnailUrl,
        subtitleController: widget.subtitleController,
        onTapSubtitle: widget.onTapSubtitle,
        state: this,
      ),
      onExit: (value) {
        _exitFullScreen();
        widget.onFullscreenChanged?.call(false);
        _isManualFullScreen = false;
        _isAutoFullScreen = false;
      },
    );
  }

  Future<void> _exitFullScreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
    _isControllerVisible = state._isControllerVisible;
    _isInitialized = state._isInitialized;
    _isLoading = state._isLoading;
    _isPlaying = state._isPlaying;
    _isBuffering = state._isBuffering;
    _current = state._current;
    _buffered = state._buffered;
    _debouncer = state._debouncer;
    _max = state._max;
    if (_isInitialized && mounted) {
      _videoController!.addListener(_listener);
    }
  }

  void _autoHideController() {
    _debouncer?.run(() {
      _setControllerVisible(false);
    });
  }
}

enum SubtitleType {
  srt,
  webvtt,
}

class SubtitleController extends ChangeNotifier {
  dynamic _data;
  SubtitleType _type;
  bool _isOff = false;

  String get data => _data;

  SubtitleType get type => _type;

  bool get isOff => _isOff;

  SubtitleController({
    required dynamic data,
    SubtitleType type = SubtitleType.srt,
  })  : assert(
          data is String || data is File,
          'Illegal argument, data must be an instance of String or File',
        ),
        _data = data,
        _type = type;

  void update(
    dynamic data, {
    SubtitleType? type,
  }) {
    _data = data;
    _type = type ?? _type;
    _isOff = false;
    notifyListeners();
  }

  void off() {
    _isOff = true;
    notifyListeners();
  }
}
