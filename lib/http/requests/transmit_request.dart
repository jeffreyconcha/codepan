import 'dart:convert';
import 'dart:io';

import 'package:codepan/extensions/map.dart';
import 'package:codepan/http/handlers.dart';
import 'package:codepan/http/requests/base_request.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

abstract class TransmitRequest<T>
    extends HttpRequest<T, List<Map<String, dynamic>>> {
  const TransmitRequest({
    required super.db,
    required super.client,
    super.logResponse,
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
    return perform(
      uri,
      headers: h..addAll(postHeaders),
      body: body,
      encoding: utf8,
    );
  }

  Future<Response> perform(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  });

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
