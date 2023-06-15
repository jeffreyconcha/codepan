import 'dart:convert';

import 'package:codepan/extensions/map.dart';
import 'package:codepan/http/base_request.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

abstract class PostRequest<T> extends HttpRequest<T> {
  const PostRequest({
    required super.db,
    required super.client,
    super.timeout,
  });

  Future<Map<String, dynamic>> get params;

  @override
  Future<Response> get request async {
    final p = await params;
    final h = await headers;
    final uri = Uri.https(authority, path);
    debugPrint('Url: ${uri.toString()}');
    return client.post(
      uri,
      headers: h..addAll(postHeaders),
      body: json.encode(p..clean()),
      encoding: utf8,
    );
  }
}
