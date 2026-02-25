import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:codepan/extensions/painter.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as i;
import 'package:image_compression/image_compression.dart';

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
      cropped = i.copyCrop(
        image,
        x: x,
        y: y,
        width: nw,
        height: nh,
      );
    } else {
      final nw = image.width;
      final nh = (nw * pr).toInt();
      final x = 0;
      final y = (image.height - nh) ~/ 2;
      print('new size: $x, $y, $nw, $nh');
      cropped = i.copyCrop(
        image,
        x: x,
        y: y,
        width: nw,
        height: nh,
      );
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
    final rotation = (exif.hasOrientation ? exif.orientation : 0) as num;
    final scale = image.width / d.maxWidth;
    final painter = builder.call(image.width, image.height, scale);
    final rendered = await painter.renderImage(
      width: image.width,
      height: image.height,
    );
    final byte = await rendered.toByteData(format: ImageByteFormat.png);
    final watermark = i.decodeImage(byte!.buffer.asUint8List())!;
    final rotated = i.copyRotate(
      watermark,
      angle: rotation,
    );
    final stamped = drawImage(image, rotated);
    final original = i.copyRotate(
      stamped,
      angle: 360 - rotation,
    );
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
    final compressed = compress(
      ImageFileConfiguration(
        input: image,
        config: Configuration(
          jpgQuality: quality,
        ),
      ),
    );
    await writeAsBytes(compressed.rawBytes);
  }

  Future<File> appendImage({
    required Uint8List attachment,
  }) async {
    final baseRaw = i.decodeImage(readAsBytesSync())!;
    final base = i.bakeOrientation(baseRaw);
    final attachmentRaw = i.decodeImage(attachment)!;
    final attachmentImg = i.bakeOrientation(attachmentRaw);
    final scale = base.width / attachmentImg.width;
    final newHeight = (attachmentImg.height * scale).toInt();
    final result = i.Image(
      width: base.width,
      height: base.height + newHeight,
    );
    for (var y = 0; y < base.height; y++) {
      for (var x = 0; x < base.width; x++) {
        result.setPixel(x, y, base.getPixel(x, y));
      }
    }
    drawImage(
      result,
      attachmentImg,
      dstX: 0,
      dstY: base.height,
      dstW: base.width,
      dstH: newHeight,
    );
    final encoded = i.encodeJpg(result);
    final data = Uint8List.fromList(encoded);
    return await writeAsBytes(data);
  }
}

i.Image drawImage(
  i.Image dst,
  i.Image src, {
  int? dstX,
  int? dstY,
  int? dstW,
  int? dstH,
  int? srcX,
  int? srcY,
  int? srcW,
  int? srcH,
  bool blend = true,
}) {
  dstX ??= 0;
  dstY ??= 0;
  srcX ??= 0;
  srcY ??= 0;
  srcW ??= src.width;
  srcH ??= src.height;
  dstW ??= (dst.width < src.width) ? dstW = dst.width : src.width;
  dstH ??= (dst.height < src.height) ? dst.height : src.height;

  if (blend) {
    for (var y = 0; y < dstH; ++y) {
      for (var x = 0; x < dstW; ++x) {
        final stepX = (x * (srcW / dstW)).toInt();
        final stepY = (y * (srcH / dstH)).toInt();
        final srcPixel = src.getPixel(srcX + stepX, srcY + stepY);
        i.drawPixel(dst, dstX + x, dstY + y, srcPixel);
      }
    }
  } else {
    for (var y = 0; y < dstH; ++y) {
      for (var x = 0; x < dstW; ++x) {
        final stepX = (x * (srcW / dstW)).toInt();
        final stepY = (y * (srcH / dstH)).toInt();
        final srcPixel = src.getPixel(srcX + stepX, srcY + stepY);
        dst.setPixel(dstX + x, dstY + y, srcPixel);
      }
    }
  }
  return dst;
}
