import 'dart:io';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:flutter/cupertino.dart';

/// In order to use this widget you need add the [camera_windows]
/// dependency on the pubspec of your main project.
class DesktopCamera extends StatefulWidget {
  final ValueChanged<File> onCapture;

  const DesktopCamera({
    super.key,
    required this.onCapture,
  });

  @override
  State<DesktopCamera> createState() => _DesktopCameraState();
}

class _DesktopCameraState extends State<DesktopCamera> {
  late double _maxWidth, _maxHeight;
  late Size _previewSize;
  int? _cameraId;

  double get aspectRatio => _previewSize.width / _previewSize.height;

  CameraPlatform get camera => CameraPlatform.instance;

  bool get isInitialized => _cameraId != null;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _resetCamera(CameraLensDirection.front);
  }

  @override
  void dispose() {
    if (isInitialized) {
      camera.dispose(_cameraId!);
    }
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
            return AspectRatio(
              aspectRatio: aspectRatio,
              child: camera.buildPreview(_cameraId!),
            );
          },
        );
      },
    );
  }

  void _resetCamera(CameraLensDirection lensDirection) async {
    final cameras = await camera.availableCameras();
    for (final camera in cameras) {
      if (camera.lensDirection == lensDirection) {
        _loadNewCamera(camera);
        break;
      }
    }
  }

  void _loadNewCamera(CameraDescription description) async {
    try {
      if (_cameraId != null) {
        camera.dispose(_cameraId!);
      }
      _cameraId = await camera.createCamera(
        description,
        ResolutionPreset.high,
        enableAudio: false,
      );
      final future = camera.onCameraInitialized(_cameraId!).first;
      await camera.initializeCamera(_cameraId!);
      final event = await future;
      _previewSize = Size(
        event.previewWidth,
        event.previewHeight,
      );
      if (mounted) setState(() {});
    } on CameraException catch (e, s) {
      printError(e, s);
    }
  }
}

class CamPlatform extends CameraPlatform {}
