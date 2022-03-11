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
import 'package:path_provider/path_provider.dart' as p;
import 'package:system_clock/system_clock.dart';

enum PanCameraEvents {
  idle,
  capture,
  switchCamera,
  initializeCamera,
}

class PanCamera extends StatefulWidget {
  final String? leftWatermark, rightWatermark;
  final CameraLensDirection lensDirection;
  final PanCameraController controller;
  final ValueChanged<File> onCapture;
  final ValueChanged<String> onError;
  final String folder;

  const PanCamera({
    Key? key,
    required this.controller,
    required this.folder,
    required this.onCapture,
    required this.onError,
    this.leftWatermark,
    this.rightWatermark,
    this.lensDirection = CameraLensDirection.back,
  }) : super(key: key);

  @override
  State<PanCamera> createState() => _PanCameraState();
}

class _PanCameraState extends LifecycleState<PanCamera> {
  late double _maxWidth, _maxHeight;
  CameraController? _controller;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
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
            if (isInitialized) {
              switch (camera!.lensDirection) {
                case CameraLensDirection.front:
                  _resetCamera(CameraLensDirection.back);
                  break;
                default:
                  _resetCamera(CameraLensDirection.front);
                  break;
              }
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
            return Transform.scale(
              scale: d.deviceRatio / value!.aspectRatio,
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
            );
          },
        );
      },
    );
  }

  void _loadNewCamera(CameraDescription description) async {
    _controller = CameraController(
      description,
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

  void _resetCamera(CameraLensDirection lensDirection) async {
    final cameras = await availableCameras();
    for (final camera in cameras) {
      if (camera.lensDirection == lensDirection) {
        _loadNewCamera(camera);
        break;
      }
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
      final private = await p.getApplicationDocumentsDirectory();
      final dir = Directory('${private.path}/${widget.folder}');
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
