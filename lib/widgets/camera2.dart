import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:codepan/extensions/directory.dart';
import 'package:codepan/extensions/extensions.dart';
import 'package:codepan/extensions/file.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:codepan/utils/text_canvas.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/states/lifecycle_state.dart';
import 'package:flutter/material.dart';
import 'package:system_clock/system_clock.dart';

enum PanCameraEvents {
  idle,
  capture,
  switchCamera,
  initializeCamera,
}

enum LensDirection {
  front(CameraLensDirection.front),
  back(CameraLensDirection.back),
  external(CameraLensDirection.external);

  final CameraLensDirection value;

  const LensDirection(this.value);
}

class PanCamera2 extends StatefulWidget {
  final String? leftWatermark, rightWatermark;
  final LensDirection lensDirection;
  final PanCameraController controller;
  final ValueChanged<File> onCapture;
  final ValueChanged<String> onError;
  final String folder;

  const PanCamera2({
    super.key,
    required this.controller,
    required this.folder,
    required this.onCapture,
    required this.onError,
    this.leftWatermark,
    this.rightWatermark,
    this.lensDirection = LensDirection.back,
  });

  @override
  State<PanCamera2> createState() => _PanCamera2State();
}

class _PanCamera2State extends LifecycleState<PanCamera2> {
  late List<CameraDescription> _cameras;
  late double _maxWidth, _maxHeight;
  PlatformCameraController? _controller;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  int _pointers = 0;

  CameraPlatform get platform => CameraPlatform.instance;

  PanCameraController get controller => widget.controller;

  CameraDescription? get camera => _controller?.description;

  bool get isInitialized => _controller?.isInitialized ?? false;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (mounted) {
        switch (controller.value) {
          case PanCameraEvents.capture:
            _capture();
            break;
          case PanCameraEvents.switchCamera:
            if (isInitialized) {
              _switchCamera(camera!);
            }
            break;
          case PanCameraEvents.initializeCamera:
            if (!isInitialized) {
              _resetCamera(widget.lensDirection);
            }
            break;
          default:
            break;
        }
        controller.value = PanCameraEvents.idle;
      }
    });
    if (Platform.isWindows) {
      _resetCamera(widget.lensDirection);
    }
  }

  @override
  void onResume() {
    super.onResume();
    if (isInitialized) {
      _loadNewCamera(camera!);
    }
  }

  @override
  void onInactive() {
    super.onInactive();
    _controller?.dispose();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return LayoutBuilder(
        builder: (context, constraints) {
          _maxWidth = constraints.maxWidth;
          _maxHeight = constraints.maxHeight;
          return IfElseBuilder(
            alignment: Alignment.center,
            condition: isInitialized,
            ifBuilder: (context) {
              final scale = 1 / (d.size.aspectRatio / _controller!.aspectRatio);
              return Listener(
                onPointerDown: (event) {
                  _pointers++;
                },
                onPointerUp: (event) {
                  _pointers--;
                },
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller!.aspectRatio,
                        child: _controller!.buildPreview(),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: _handleScaleStart,
                        onScaleUpdate: _handleScaleUpdate,
                        onTapDown: (details) {
                          onViewFinderTap(details);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  void _loadNewCamera(CameraDescription description) async {
    _controller?.dispose();
    _controller = PlatformCameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      onError: (error) {
        debugPrint(error.description);
      },
    );
    _controller!.addListener(() {
      debugPrint('camera initialized');
      if (mounted) setState(() {});
    });
    try {
      await _controller!.initialize();
      await _controller!.unlockCaptureOrientation();
      await _controller!.setFlashMode(FlashMode.off);
      _minAvailableZoom = await _controller!.getMinZoomLevel();
      _maxAvailableZoom = await _controller!.getMaxZoomLevel();
    } on CameraException catch (error, stackTrace) {
      printError(error, stackTrace);
    }
    if (mounted) setState(() {});
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (_controller != null && _pointers == 2) {
      _currentScale = (_baseScale * details.scale)
          .clamp(_minAvailableZoom, _maxAvailableZoom);
      await _controller!.setZoomLevel(_currentScale);
    }
  }

  void onViewFinderTap(TapDownDetails details) {
    if (_controller != null) {
      final size = _controller!.previewSize;
      final point = Point<double>(
        details.localPosition.dx / size.width,
        details.localPosition.dy / size.height,
      );
      _controller!.setExposurePoint(point);
      _controller!.setFocusPoint(point);
    }
  }

  void _resetCamera(LensDirection lensDirection) async {
    final cameras = await platform.availableCameras();
    _cameras = List.of(cameras);
    debugPrint('No. of cameras: ${cameras.length}');
    for (final camera in cameras) {
      if (camera.lensDirection == lensDirection.value) {
        _loadNewCamera(camera);
        break;
      }
    }
  }

  void _switchCamera(CameraDescription current) async {
    if (current != _cameras.last) {
      final index = _cameras.indexOf(current);
      _loadNewCamera(_cameras[index + 1]);
    } else {
      _loadNewCamera(_cameras.first);
    }
  }

  Future<File> _stampImage({
    required File file,
    required String watermark,
  }) async {
    final d = Dimension.of(context);
    return await file.stampImage(
      context: context,
      builder: (width, height, scale) {
        final lineCount = watermark
            .split('\n')
            .length;
        final fontSize = d.at(11);
        final margin = d.at(8);
        final contentHeight = (fontSize * scale * lineCount) + margin;
        final dx = margin;
        final dy = height.toDouble() - contentHeight;
        return TextCanvas(
          text: watermark,
          textScaleFactor: scale,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            shadows: <Shadow>[
              Shadow(
                color: Colors.black26,
                blurRadius: d.at(2),
                offset: Offset(-d.at(1), d.at(1)),
              )
            ],
          ),
          offset: Offset(dx, dy),
        );
      },
    );
  }

  Future<void> _capture() async {
    if (isInitialized && !controller.isTakingPhoto()) {
      controller._isTakingPhoto = true;
      final elapsed = SystemClock
          .elapsedRealtime()
          .inMilliseconds;
      final stamp = DateTime
          .now()
          .millisecondsSinceEpoch;
      final private = await PanUtils.getAppDirectory();
      final dir = private.of(widget.folder);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final fileName = '$elapsed-$stamp.jpg';
      final path = '${dir.path}/$fileName';
      try {
        final captured = await _controller!.takePicture();
        final file = File(captured.path);
        final copied = await file.copy(path);
        final cropped = await copied.cropImage(
          preferredWidth: _maxWidth,
          preferredHeight: _maxHeight,
        );
        final watermark = widget.leftWatermark;
        if (watermark != null) {
          final stamped =
          await _stampImage(file: cropped, watermark: watermark);
          final photo = await copied.writeAsBytes(stamped.readAsBytesSync());
          widget.onCapture(photo);
        } else {
          final photo = await copied.writeAsBytes(cropped.readAsBytesSync());
          widget.onCapture(photo);
        }
      } catch (error, stackTrace) {
        widget.onError(error.toString());
        printError(error, stackTrace);
      } finally {
        controller._isTakingPhoto = false;
      }
    }
  }
}

class PlatformCameraController extends ValueNotifier<CameraDescription> {
  final ValueChanged<CameraClosingEvent>? onClose;
  final ValueChanged<CameraErrorEvent>? onError;
  final ResolutionPreset resolutionPreset;
  final CameraDescription description;
  final bool enableAudio;
  StreamSubscription<CameraClosingEvent>? _closeStream;
  StreamSubscription<CameraErrorEvent>? _errorStream;
  late final bool _isInitialized;
  late final Size _previewSize;
  late final int _cameraId;

  CameraPlatform get platform => CameraPlatform.instance;

  double get aspectRatio => previewSize.aspectRatio;

  bool get isMobile => Platform.isAndroid || Platform.isIOS;

  bool get isInitialized => _isInitialized;

  Size get previewSize => _previewSize;

  int get cameraId => _cameraId;

  PlatformCameraController(this.description,
      this.resolutionPreset, {
        this.enableAudio = false,
        this.onClose,
        this.onError,
      }) : super(description);

  @override
  void dispose() {
    _errorStream?.cancel();
    _closeStream?.cancel();
    platform.dispose(cameraId);
    super.dispose();
  }

  Future<void> initialize() async {
    try {
      _cameraId = await platform.createCamera(
        description,
        resolutionPreset,
        enableAudio: enableAudio,
      );
      if (onError != null) {
        final errorStream = platform.onCameraError(cameraId);
        _errorStream = errorStream.listen(onError);
      }
      if (onClose != null) {
        final closingStream = platform.onCameraClosing(cameraId);
        _closeStream = closingStream.listen(onClose);
      }
      final future = platform
          .onCameraInitialized(cameraId)
          .first;
      await platform.initializeCamera(cameraId);
      final event = await future;
      _previewSize = Size(
        event.previewWidth,
        event.previewHeight,
      );
      _isInitialized = true;
      value = description;
    } on CameraException catch (e, s) {
      printError(e, s);
    }
  }

  Widget buildPreview() {
    return platform.buildPreview(cameraId);
  }

  Future<XFile> takePicture() {
    return platform.takePicture(cameraId);
  }

  Future<void> unlockCaptureOrientation() async {
    if (isMobile) {
      await platform.unlockCaptureOrientation(cameraId);
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (isMobile) {
      await platform.setFlashMode(cameraId, mode);
    }
  }

  Future<double> getMinZoomLevel() async {
    if (isMobile) {
      return await platform.getMinZoomLevel(cameraId);
    }
    return 0;
  }

  Future<double> getMaxZoomLevel() async {
    if (isMobile) {
      return await platform.getMaxZoomLevel(cameraId);
    }
    return 0;
  }

  Future<void> setZoomLevel(double level) async {
    if (isMobile) {
      await platform.setZoomLevel(cameraId, level);
    }
  }

  Future<void> setExposurePoint(Point<double>? point) async {
    if (isMobile) {
      await platform.setExposurePoint(cameraId, point);
    }
  }

  Future<void> setFocusPoint(Point<double>? point) async {
    if (isMobile) {
      await platform.setFocusPoint(cameraId, point);
    }
  }
}

class PanCameraController extends ValueNotifier<PanCameraEvents> {
  PanCameraController() : super(PanCameraEvents.idle);

  bool _isTakingPhoto = false;

  bool isTakingPhoto() {
    return _isTakingPhoto;
  }

  void capture() {
    value = PanCameraEvents.capture;
  }

  void switchCamera() {
    value = PanCameraEvents.switchCamera;
  }

  void initializeCamera() {
    value = PanCameraEvents.initializeCamera;
  }
}
