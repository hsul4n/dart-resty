import 'dart:convert' as converter show json;

class Response {
  final int statusCode;
  final String body;

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

  Response({this.statusCode, this.body})
      : isSuccess = statusCode >= 200 && statusCode < 300,
        isOk = statusCode >= 200 && statusCode < 300,
        isRedirect = statusCode >= 300 && statusCode < 400,
        isClientError = statusCode >= 400 && statusCode < 500,
        isServerError = statusCode >= 500;
}
