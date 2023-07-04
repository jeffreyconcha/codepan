import 'dart:convert';
import 'dart:io';

import 'package:codepan/data/database/sqlite_adapter.dart';
import 'package:codepan/http/handlers/handler.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

const _timeout = Duration(seconds: 30);

const postHeaders = <String, String>{
  'Content-Type': 'application/json',
};
const getHeaders = <String, String>{
  'Content-Type': 'application/x-www-form-urlencoded',
};
const uploadHeaders = <String, String>{
  'Content-Type': 'multipart/form-data',
};

abstract class HttpRequestResult<T> {
  Future<T> onSuccess(List<Map<String, dynamic>> json);

  Future<String> onError(int code);
}

abstract class HttpRequest<T> implements HttpRequestResult<T> {
  final SqliteAdapter db;
  final Client client;

  const HttpRequest({
    required this.db,
    required this.client,
  });

  String get authority;

  String get path;

  Future<Map<String, String>> get headers;

  Future<Response> get response;

  InitHandler get handler;

  Future<T> send({
    Duration? timeout,
  }) async {
    final result = await response.timeout(timeout ?? _timeout);
    debugPrint('Body: ${result.body}');
    debugPrint('Response Code: ${result.statusCode}');
    if (result.statusCode == HttpStatus.ok) {
      final body = json.decode(result.body);
      final data = handler.init(body);
      if (data.isNotEmpty || handler.allowEmpty) {
        return await onSuccess(data);
      }
    }
    throw await onError(result.statusCode);
  }
}
