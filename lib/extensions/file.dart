import 'dart:io';
import 'dart:math' as m;
import 'dart:typed_data';
import 'dart:ui';
import 'package:codepan/extensions/painter.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image/image.dart' as i;

typedef PainterBuilder = CustomPainter Function(
  int width,
  int height,
  double scale,
);

extension FileUtils on File {
  String get name {
    final separator = Platform.pathSeparator;
    return this?.path?.split(separator)?.last;
  }

  Future<File> cropImage({
    @required double preferredWidth,
    @required double preferredHeight,
  }) async {
    final image = i.decodeImage(this.readAsBytesSync());
    final preferredRatio = preferredWidth / preferredHeight;
    final min = m.min(image.width, image.height);
    final max = m.max(image.width, image.height);
    final isPortrait = image.height > image.width;
    final imageRatio = min / max;
    File cropped;
    print('is portrait: $isPortrait');
    print('original size: $min x $max');
    if (isPortrait) {
      if (preferredRatio < imageRatio) {
        final height = max;
        final width = (height * preferredRatio).toInt();
        final originY = 0;
        final originX = (min - width) ~/ 2;
        print('output 1: $width x $height @$originX,$originY');
        cropped = await FlutterNativeImage.cropImage(
            this.path, originX, originY, width, height);
      } else {
        final width = min;
        final height = width ~/ preferredRatio;
        final originX = 0;
        final originY = (max - height) ~/ 2;
        print('output 2: $width x $height @$originX,$originY');
        cropped = await FlutterNativeImage.cropImage(
            this.path, originX, originY, width, height);
      }
    } else {
      if (preferredRatio < imageRatio) {
        final width = max;
        final height = (width * preferredRatio).toInt();
        final originX = 0;
        final originY = (min - height) ~/ 2;
        print('output 3: $width x $height @$originX,$originY');
        cropped = await FlutterNativeImage.cropImage(
            this.path, originX, originY, width, height);
      } else {
        final height = min;
        final width = height ~/ preferredRatio;
        final originY = 0;
        final originX = (max - width) ~/ 2;
        print('output 4: $width x $height @$originX,$originY');
        cropped = await FlutterNativeImage.cropImage(
            this.path, originX, originY, width, height);
      }
    }
    return cropped;
  }

  Future<File> stampImage({
    @required PainterBuilder builder,
    @required BuildContext context,
  }) async {
    final d = Dimension.of(context);
    final rotation = await getImageRotation();
    final rotated = await getRotatedImage();
    final min = m.min(rotated.width, rotated.height);
    final scale = min / d.min;
    final painter = builder.call(
      rotated.width,
      rotated.height,
      scale,
    );
    final rendered = await painter.renderImage(
      width: rotated.width,
      height: rotated.height,
    );
    final byte = await rendered.toByteData(
      format: ImageByteFormat.png,
    );
    final stamp = i.decodeImage(byte.buffer.asUint8List());
    final stamped = i.drawImage(rotated, stamp);
    final original = i.copyRotate(stamped, 360 - rotation);
    final encoded = i.encodeJpg(original);
    final data = Uint8List.fromList(encoded);
    return await this.writeAsBytes(data);
  }

  Future<int> getImageRotation() async {
    final properties = await FlutterNativeImage.getImageProperties(path);
    switch (properties.orientation) {
      case ImageOrientation.rotate90:
        return 90;
        break;
      case ImageOrientation.rotate180:
        return 180;
        break;
      case ImageOrientation.rotate270:
        return 270;
        break;
      default:
    }
    return 0;
  }

  Future<i.Image> getRotatedImage() async {
    final image = i.decodeImage(this.readAsBytesSync());
    final rotation = await getImageRotation();
    return i.copyRotate(image, rotation);
  }

  Future<Uint8List> get jpegData async {
    final image = await getRotatedImage();
    final encoded = i.encodeJpg(image);
    return Uint8List.fromList(encoded);
  }

  Future<Uint8List> get pngData async {
    final image = await getRotatedImage();
    final encoded = i.encodePng(image);
    return Uint8List.fromList(encoded);
  }
}
