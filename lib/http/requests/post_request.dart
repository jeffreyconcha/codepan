import 'dart:convert';

import 'package:codepan/extensions/map.dart';
import 'package:codepan/http/requests/base_request.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

const indent = '    ';

abstract class PostRequest<T> extends HttpRequest<T> {
  const PostRequest({
    required super.db,
    required super.client,
  });

  Future<Map<String, dynamic>> get params;

  @override
  Future<Response> get response async {
    final p = await params;
    final h = await headers;
    final uri = Uri.https(authority, path);
    final encoder = JsonEncoder.withIndent(indent);
    final body = encoder.convert(p..clean());
    debugPrint('Url: ${uri.toString()}');
    debugPrint('Payload:\n${body.toString()}');
    return client.post(
      uri,
      headers: h..addAll(postHeaders),
      body: body,
      encoding: utf8,
    );
  }
}

abstract class UploadRequest<T> extends HttpRequest<T> {
  const UploadRequest({
    required super.db,
    required super.client,
  });

  Future<Map<String, String>> get fields;

  List<MultipartFile> get files;

  @override
  Future<Response> get response async {
    final f = await fields;
    final h = await headers;
    final uri = Uri.https(authority, path);
    final encoder = JsonEncoder.withIndent(indent);
    final body = encoder.convert(f..clean());
    debugPrint('Url: ${uri.toString()}');
    debugPrint('Payload:\n${body.toString()}');
    final request = MultipartRequest('POST', uri);
    request.headers.addAll(h..addAll(uploadHeaders));
    request.fields.addAll(f);
    request.files.addAll(files);
    final stream = await request.send();
    return await Response.fromStream(stream);
  }
}
