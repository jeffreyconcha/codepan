import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
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
  rotate,
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

class PanCamera extends StatefulWidget {
  final String? leftWatermark, rightWatermark;
  final LensDirection lensDirection;
  final PanCameraController controller;
  final ValueChanged<File> onCapture;
  final ValueChanged<String> onError;
  final Directory directory;

  const PanCamera({
    super.key,
    required this.controller,
    required this.directory,
    required this.onCapture,
    required this.onError,
    this.leftWatermark,
    this.rightWatermark,
    this.lensDirection = LensDirection.back,
  });

  @override
  State<PanCamera> createState() => _PanCameraState();
}

class _PanCameraState extends LifecycleState<PanCamera> {
  late List<CameraDescription> _cameras;
  late double _maxWidth, _maxHeight;
  _CameraController? _controller;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  int _rotation = 0;
  int _pointers = 0;

  PanCameraController get controller => widget.controller;

  CameraDescription? get camera => _controller?.description;

  CameraValue? get value => _controller?.value;

  bool get isInitialized => value?.isInitialized ?? false;

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
            _switchCamera(_controller!.description);
            break;
          case PanCameraEvents.initializeCamera:
            _resetCamera(widget.lensDirection);
            break;
          case PanCameraEvents.rotate:
            _rotate();
            break;
          default:
            break;
        }
        controller.value = PanCameraEvents.idle;
      }
    });
    if (isDesktop) {
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
            final pr = value!.aspectRatio;
            return RotatedBox(
              quarterTurns: _rotation,
              child: Transform.scale(
                scale: isDesktop
                    ? 1 / (d.size.aspectRatio / pr)
                    : d.deviceRatio / pr,
                child: Listener(
                  onPointerDown: (event) {
                    _pointers++;
                  },
                  onPointerUp: (event) {
                    _pointers--;
                  },
                  child: CameraPreview(
                    _controller!,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onScaleStart: _handleScaleStart,
                      onScaleUpdate: _handleScaleUpdate,
                      onTapDown: (details) {
                        onViewFinderTap(details, constraints);
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _loadNewCamera(CameraDescription camera) async {
    print('Camera: ${camera.name}');
    print('Lens: ${camera.lensDirection}');
    if (!isInitialized) {
      _controller = _CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _controller!.addListener(() {
        if (mounted) setState(() {});
        if (value?.hasError ?? false) {
          debugPrint(value!.errorDescription);
        }
      });
      try {
        await _controller!.initialize();
      } on CameraException catch (error, stackTrace) {
        print('camera error $error');
        printError(error, stackTrace);
      }
    } else {
      _controller!.setDescription(camera);
    }
    await _controller!.unlockCaptureOrientation();
    await _controller!.setFlashMode(FlashMode.off);
    _minAvailableZoom = await _controller!.getMinZoomLevel();
    _maxAvailableZoom = await _controller!.getMaxZoomLevel();
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

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (_controller != null) {
      final offset = Offset(
        details.localPosition.dx / constraints.maxWidth,
        details.localPosition.dy / constraints.maxHeight,
      );
      _controller!.setExposurePoint(offset);
      _controller!.setFocusPoint(offset);
    }
  }

  void _resetCamera(LensDirection lensDirection) async {
    final cameras = await availableCameras();
    _cameras = List.of(cameras);
    print('No of cameras: ${_cameras.length}');
    for (final camera in cameras) {
      if (camera.lensDirection == lensDirection.value) {
        _loadNewCamera(camera);
        break;
      }
    }
  }

  void _switchCamera(CameraDescription current) async {
    if (_cameras.isNotEmpty) {
      CameraDescription camera = _cameras.first;
      if (current != _cameras.last) {
        final index = _cameras.indexOf(current) + 1;
        camera = _cameras[index];
      }
      _loadNewCamera(camera);
    }
  }

  void _rotate() {
    setState(() {
      _rotation += 1;
    });
  }

  Future<File> _stampImage({
    required File file,
    required String watermark,
  }) async {
    final d = Dimension.of(context);
    return await file.stampImage(
      context: context,
      builder: (width, height, scale) {
        final lineCount = watermark.split('\n').length;
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
    if (isInitialized &&
        !value!.isTakingPicture &&
        !controller.isTakingPhoto()) {
      controller._isTakingPhoto = true;
      final elapsed = SystemClock.elapsedRealtime().inMilliseconds;
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final dir = widget.directory;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final slash = Platform.pathSeparator;
      final fileName = '$elapsed-$stamp.jpg';
      final path = '${dir.path}$slash$fileName';
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

  void rotate() {
    value = PanCameraEvents.rotate;
  }

  void initializeCamera() {
    value = PanCameraEvents.initializeCamera;
  }
}

class _CameraController extends CameraController {
  _CameraController(
    super.description,
    super.resolutionPreset, {
    super.enableAudio = true,
    super.imageFormatGroup,
  });

  @override
  Future<void> unlockCaptureOrientation() async {
    if (!isDesktop) {
      return super.unlockCaptureOrientation();
    }
  }

  @override
  Future<void> setFlashMode(FlashMode mode) async {
    if (!isDesktop) {
      return super.setFlashMode(mode);
    }
  }

  @override
  Future<void> setExposurePoint(Offset? point) async {
    if (!isDesktop) {
      return super.setExposurePoint(point);
    }
  }

  @override
  Future<void> setExposureMode(ExposureMode mode) async {
    if (!isDesktop) {
      return super.setExposureMode(mode);
    }
  }

  @override
  Future<void> setFocusPoint(Offset? point) async {
    if (!isDesktop) {
      return super.setFocusPoint(point);
    }
  }

  @override
  Future<void> setFocusMode(FocusMode mode) async {
    if (!isDesktop) {
      return super.setFocusMode(mode);
    }
  }

  @override
  Future<void> setZoomLevel(double zoom) async {
    if (!isDesktop) {
      return super.setZoomLevel(zoom);
    }
  }

  @override
  Future<double> getMinZoomLevel() async {
    if (!isDesktop) {
      return super.getMinZoomLevel();
    }
    return 0;
  }

  @override
  Future<double> getMaxZoomLevel() async {
    if (!isDesktop) {
      return super.getMaxZoomLevel();
    }
    return 0;
  }
}
