import 'dart:io';

abstract class Observe {
  const Observe();

  Future onRequest(HttpClientRequest request) async => request;

  Future onResponse(HttpClientResponse response) async => response;

  Future onError(Exception exception) async => exception;
}
