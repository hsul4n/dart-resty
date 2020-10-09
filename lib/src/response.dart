import 'dart:convert' as converter show json;

import 'dart:io' show HttpHeaders;

class Response {
  final String body;
  final HttpHeaders headers;
  final int statusCode;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isOk => isSuccess;
  bool get isRedirect => statusCode >= 300 && statusCode < 400;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;

  dynamic get json {
    try {
      return converter.json.decode(body);
    } catch (_) {
      return null;
    }
  }

  const Response({this.body, this.headers, this.statusCode});
}
