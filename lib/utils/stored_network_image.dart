import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:codepan/extensions/file.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:codepan/utils/debouncer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:uuid/uuid.dart';

const _defaultFolder = 'StoredImages';
const _defaultFileLimit = 1000;
const _tag = 'StoredNetworkImage';
const uuid = const Uuid();

class StoredNetworkImage extends ImageProvider<StoredNetworkImage> {
  final Debouncer? debouncer;
  final String imageUrl;
  final String folder;
  final double scale;
  final int fileLimit;

  StoredNetworkImage(
    this.imageUrl, {
    this.scale = 1.0,
    this.folder = _defaultFolder,
    this.fileLimit = _defaultFileLimit,
    this.debouncer,
  });

  final retryClient = RetryClient(Client());

  Future<File> loadFile() async {
    return PanUtils.getFile(
      fileName: fileName,
      folder: folder,
    );
  }

  String get fileName => uuid.v5(Uuid.NAMESPACE_URL, imageUrl);

  @override
  Future<StoredNetworkImage> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture<StoredNetworkImage>(this);
  }

  @override
  ImageStreamCompleter load(
    StoredNetworkImage key,
    DecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: key.imageUrl,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Path: ${key.imageUrl}'),
      ],
    );
  }

  Future<Uint8List> getImageData() async {
    final file = await loadFile();
    if (await file.exists()) {
      final data = await file.readAsBytes();
      if (data.isNotEmpty) {
        return data;
      }
    }
    final uri = Uri.parse(imageUrl);
    final response = await retryClient.get(uri);
    return _saveImage(response.bodyBytes);
  }

  Uint8List _saveImage(Uint8List data) {
    loadFile().then((file) {
      file.writeAsBytes(data);
    });
    debouncer?.run(() async {
      final dir = await PanUtils.getDirectory(folder);
      final entities = await dir.list().toList();
      final length = entities.length;
      if (length >= fileLimit) {
        final excess = length - fileLimit;
        for (final index in range(0, excess)) {
          final entity = entities[index];
          try {
            if (await entity.exists()) {
              await entity.delete();
              debugPrint('$_tag: File deleted: ${entity.name}.');
            }
          } catch (error) {
            debugPrint('$_tag: Unable to delete ${entity.name}.');
          }
        }
      }
    });
    return data;
  }

  Future<Codec> _loadAsync(
    StoredNetworkImage key,
    DecoderCallback decode,
  ) async {
    assert(key == this);
    final data = await getImageData();
    if (data.isEmpty) {
      PaintingBinding.instance!.imageCache!.evict(key);
      throw StateError(
        '${key.imageUrl} cannot be loaded as an image.',
      );
    }
    return decode(data);
  }

  @override
  bool operator ==(dynamic other) {
    if (other is StoredNetworkImage) {
      return imageUrl == other.imageUrl && scale == other.scale;
    }
    return false;
  }

  @override
  int get hashCode => imageUrl.hashCode;
}
