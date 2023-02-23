import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:codepan/extensions/painter.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as i;
import 'package:image_compression_flutter/image_compression_flutter.dart';

typedef PainterBuilder = CustomPainter Function(
  int width,
  int height,
  double scale,
);

extension FileSystemEntityUtils on FileSystemEntity {
  String get name {
    final separator = Platform.pathSeparator;
    return this.path.split(separator).last;
  }
}

extension ImageUtils on File {
  Future<File> cropImage({
    required double preferredWidth,
    required double preferredHeight,
  }) async {
    final image = i.decodeImage(this.readAsBytesSync())!;
    final pr = preferredWidth / preferredHeight;
    final ir = image.width / image.height;
    i.Image cropped;
    if (ir > pr) {
      final nh = image.height; //720
      final nw = (nh * pr).toInt(); // 1008
      final x = (image.width - nw) ~/ 2;
      final y = 0;
      print('new size: $x, $y, $nw, $nh');
      cropped = i.copyCrop(image, x, y, nw, nh);
    } else {
      final nw = image.width;
      final nh = (nw * pr).toInt();
      final x = 0;
      final y = (image.height - nh) ~/ 2;
      print('new size: $x, $y, $nw, $nh');
      cropped = i.copyCrop(image, x, y, nw, nh);
    }
    final encoded = i.encodeJpg(cropped);
    final data = Uint8List.fromList(encoded);
    return await this.writeAsBytes(data);
  }

  Future<File> stampImage({
    required PainterBuilder builder,
    required BuildContext context,
  }) async {
    final d = Dimension.of(context);
    final raw = i.decodeImage(this.readAsBytesSync())!;
    final image = i.bakeOrientation(raw);
    final exif = image.exif.exifIfd;
    final rotation = (exif.hasOrientation ? exif.Orientation : 0) as num;
    final scale = image.width / d.maxWidth;
    final painter = builder.call(image.width, image.height, scale);
    final rendered = await painter.renderImage(
      width: image.width,
      height: image.height,
    );
    final byte = await rendered.toByteData(format: ImageByteFormat.png);
    final watermark = i.decodeImage(byte!.buffer.asUint8List())!;
    final rotated = i.copyRotate(watermark, rotation);
    final stamped = i.drawImage(image, rotated);
    final original = i.copyRotate(stamped, 360 - rotation);
    final encoded = i.encodeJpg(original);
    final data = Uint8List.fromList(encoded);
    return await this.writeAsBytes(data);
  }

  Future<i.Image> getRotatedImage() async {
    final image = i.decodeImage(this.readAsBytesSync())!;
    return i.bakeOrientation(image);
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

  Future<void> compressImage({
    int quality = 90,
  }) async {
    final image = ImageFile(
      filePath: path,
      rawBytes: await readAsBytes(),
    );
    final compressed = await compressor.compress(
      ImageFileConfiguration(
        input: image,
        config: Configuration(
          quality: quality,
        ),
      ),
    );
    await writeAsBytes(compressed.rawBytes);
  }
}
