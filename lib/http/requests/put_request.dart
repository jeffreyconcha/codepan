import 'dart:convert';

import 'package:codepan/http/requests/transmit_request.dart';
import 'package:http/http.dart';

abstract class PutRequest<T> extends TransmitRequest<T> {
  const PutRequest({
    required super.db,
    required super.client,
  });

  @override
  Future<Response> perform(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return client.put(
      uri,
      headers: headers,
      body: body,
      encoding: utf8,
    );
  }
}
