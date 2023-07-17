import 'dart:convert';
import 'dart:io';

import 'package:codepan/data/database/sqlite_adapter.dart';
import 'package:codepan/http/handlers.dart';
import 'package:codepan/http/requests/download_request.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

const _timeout = Duration(seconds: 30);
const indent = '    ';

const postHeaders = <String, String>{
  'Content-Type': 'application/json',
};
const getHeaders = <String, String>{
  'Content-Type': 'application/x-www-form-urlencoded',
};
const uploadHeaders = <String, String>{
  'Content-Type': 'multipart/form-data',
};

abstract class HttpRequestResult<T, B> {
  Future<T> onSuccess(B body);

  Future<String> onError(int code);
}

abstract class HttpRequest<T, B> implements HttpRequestResult<T, B> {
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
    if (this is! DownloadRequest) {
      debugPrint('Body: ${result.body}');
    }
    debugPrint('Response Code: ${result.statusCode}');
    return onResponse(result);
  }

  Future<T> onResponse(Response response);
}
