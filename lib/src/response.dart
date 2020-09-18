import 'dart:convert' as converter show json;

import 'dart:io';

class Response {
  final String body;
  final HttpHeaders headers;
  final int statusCode;

  final bool isSuccess;
  final bool isOk;
  final bool isRedirect;
  final bool isClientError;
  final bool isServerError;

  dynamic get json {
    try {
      return converter.json.decode(body);
    } catch (_) {
      return null;
    }
  }

  Response({this.body, this.headers, this.statusCode})
      : isSuccess = statusCode >= 200 && statusCode < 300,
        isOk = statusCode >= 200 && statusCode < 300,
        isRedirect = statusCode >= 300 && statusCode < 400,
        isClientError = statusCode >= 400 && statusCode < 500,
        isServerError = statusCode >= 500;
}
