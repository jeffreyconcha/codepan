import 'dart:convert';
import 'dart:io';

import 'package:codepan/extensions/map.dart';
import 'package:codepan/http/handlers.dart';
import 'package:codepan/http/requests/base_request.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

abstract class DownloadRequest<T> extends HttpRequest<T, Uint8List> {
  const DownloadRequest({
    required super.db,
    required super.client,
  });

  Future<Map<String, String?>> get params;

  @override
  Future<Response> get response async {
    final p = await params;
    final h = await headers;
    final uri = Uri.https(authority, path, p..clean());
    debugPrint('Url: ${uri.toString()}');
    debugPrint('Headers: ${h.toString()}');
    return client.get(
      uri,
      headers: h..addAll(getHeaders),
    );
  }

  @override
  ByteInitHandler get handler => const ByteInitHandler(false);

  @override
  Future<T> onResponse(Response response) async {
    if (response.statusCode == HttpStatus.ok) {
      final data = handler.init(response.bodyBytes);
      if (data.isNotEmpty || handler.allowEmpty) {
        return await onSuccess(data);
      }
    }
    throw await onError(response.statusCode);
  }
}
