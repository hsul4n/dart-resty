import 'dart:io' show HttpClientRequest, HttpClientResponse;

import 'package:resty/src/observe.dart';

class Observer extends Observe {
  final dynamic Function(HttpClientRequest) _onRequest;
  final dynamic Function(HttpClientResponse) _onResponse;
  final dynamic Function(Exception) _onError;

  Observer({
    dynamic Function(HttpClientRequest) onRequest,
    dynamic Function(HttpClientResponse) onResponse,
    dynamic Function(Exception) onError,
  })  : _onRequest = onRequest,
        _onResponse = onResponse,
        _onError = onError;

  @override
  Future onRequest(HttpClientRequest request) async =>
      _onRequest != null ? await _onRequest(request) : request;

  @override
  Future onResponse(HttpClientResponse response) async =>
      _onResponse != null ? await _onResponse(response) : response;

  @override
  Future onError(Exception exception) async =>
      _onError != null ? await _onError(exception) : exception;
}
