import 'dart:convert';

import 'package:codepan/http/requests/transmit_request.dart';
import 'package:http/http.dart';

abstract class PostRequest<T> extends TransmitRequest<T> {
  const PostRequest({
    required super.db,
    required super.client,
    super.logResponse,
  });

  @override
  Future<Response> perform(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return client.post(
      uri,
      headers: headers,
      body: body,
      encoding: utf8,
    );
  }
}
