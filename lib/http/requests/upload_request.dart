import 'dart:convert';
import 'dart:io';

import 'package:codepan/extensions/map.dart';
import 'package:codepan/http/handlers.dart';
import 'package:codepan/http/requests/base_request.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

abstract class UploadRequest<T>
    extends HttpRequest<T, List<Map<String, dynamic>>> {
  const UploadRequest({
    required super.db,
    required super.client,
    super.logResponse,
  });

  Future<Map<String, String>> get fields;

  Future<List<MultipartFile>> get files;

  @override
  Future<Response> get response async {
    final f = await fields;
    final h = await headers;
    final m = await files;
    final uri = Uri.https(authority, path);
    final encoder = JsonEncoder.withIndent(indent);
    final body = encoder.convert(f..clean());
    debugPrint('Url: ${uri.toString()}');
    debugPrint('Payload:\n${body.toString()}');
    final request = MultipartRequest('POST', uri);
    request.headers.addAll(h..addAll(uploadHeaders));
    request.fields.addAll(f);
    request.files.addAll(m);
    final stream = await request.send();
    return await Response.fromStream(stream);
  }

  @override
  DataInitHandler get handler;

  @override
  Future<T> onResponse(Response response) async {
    if (response.statusCode == HttpStatus.ok) {
      try {
        final body = json.decode(response.body);
        final data = handler.init(body);
        if (data.isNotEmpty || handler.allowEmpty) {
          return await onSuccess(data);
        }
      } on DataInitException catch (e) {
        throw await onError(response.statusCode, e.message);
      } catch (e, s) {
        printError(e, s);
      }
    }
    throw await onError(response.statusCode);
  }
}
