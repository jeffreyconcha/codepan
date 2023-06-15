import 'package:codepan/extensions/map.dart';
import 'package:codepan/http/base_request.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

abstract class GetRequest<T> extends HttpRequest<T> {
  const GetRequest({
    required super.db,
    required super.client,
    super.timeout,
  });

  Future<Map<String, String?>> get params;

  @override
  Future<Response> get request async {
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
}
