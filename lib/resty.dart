library resty;

import 'dart:async' show StreamTransformer;
import 'dart:io'
    show
        ContentType,
        HttpClient,
        HttpClientCredentials,
        HttpHeaders,
        SecurityContext;
import 'dart:convert' as converter show utf8, json, JsonEncoder;
import 'dart:typed_data' show ByteData;

import 'src/progress.dart';
import 'src/response.dart';
import 'src/observer.dart';

export 'dart:io' show HttpClientBasicCredentials, HttpClientDigestCredentials;
export 'src/response.dart';
export 'src/observer.dart';

typedef _ProgressCallback = void Function(Progress progress);

class Resty {
  /// pass to use `https`
  final bool secure;

  /// see: [HttpClientCredentials]
  final HttpClientCredentials auth;

  /// see: [Uri.http] or [Uri.https]
  final String host;

  // your port
  final int port;

  /// your base path
  final String path;

  /// api version if exists
  final String version;

  /// use to set Accept & [Conntent-Type]
  final bool json;

  // use to enable log into console
  final bool logger;

  /// default headers
  final Map<String, dynamic> headers;

  // connection timeout
  final Duration timeout;

  /// pass certificate to use ssl
  final ByteData certificate;

  /// pass to observer requests & responses or catch errors
  final List<Observer> observers;

  const Resty({
    final bool secure,
    final this.auth,
    final this.host,
    final this.port,
    final this.path,
    final this.headers = const {},
    final this.version,
    final this.json = false,
    final this.logger = false,
    final this.timeout,
    final this.certificate,
    final this.observers = const [],
  })  :

        /// set [secure] true if certificate passed else use the given value
        secure = secure ?? certificate != null,
        assert(host != null),
        assert(headers != null),
        assert(json != null),
        assert(logger != null),
        assert(observers != null);

  /// see [HttpClient.get]
  Future<Response> get(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic> query,
    _ProgressCallback progress,
  }) =>
      _request(
        method: 'GET',
        uri: _buildUri(endpoint, version, query),
        headers: headers,
        progress: progress,
      );

  /// see [HttpClient.post]
  Future<Response> post(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    dynamic body,
    _ProgressCallback progress,
  }) =>
      _request(
        method: 'POST',
        uri: _buildUri(endpoint, version),
        headers: headers,
        body: body,
        progress: progress,
      );

  /// see [HttpClient.put]
  Future<Response> put(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    dynamic body,
    _ProgressCallback progress,
  }) =>
      _request(
        method: 'PUT',
        uri: _buildUri(endpoint, version),
        headers: headers,
        body: body,
        progress: progress,
      );

  /// see [HttpClient.patch]
  Future<Response> patch(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    dynamic body,
    _ProgressCallback progress,
  }) =>
      _request(
        method: 'PATCH',
        uri: _buildUri(endpoint, version),
        headers: headers,
        body: body,
        progress: progress,
      );

  /// see [HttpClient.delete]
  Future<Response> delete(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic> query,
    _ProgressCallback progress,
  }) =>
      _request(
        method: 'DELETE',
        uri: _buildUri(endpoint, version, query),
        headers: headers,
        progress: progress,
      );

  /// see [HttpClient.openUrl]
  Future<Response> _request({
    String method,
    Uri uri,
    Map<String, dynamic> headers,
    dynamic body,
    _ProgressCallback progress,
  }) async {
    try {
      final bodyBytes = converter.utf8.encode(converter.json.encode(body));

      SecurityContext httpClientContext;

      if (certificate != null)
        httpClientContext = SecurityContext()
          ..setTrustedCertificatesBytes(certificate.buffer.asUint8List());
      else
        httpClientContext = SecurityContext.defaultContext;

      final httpClient = HttpClient(context: httpClientContext);

      if (timeout != null) httpClient.connectionTimeout = timeout;

      if (auth != null)
        httpClient.authenticate = (url, _, realm) {
          httpClient.addCredentials(url, realm, auth);

          return Future.value(true);
        };

      final httpRequest = await httpClient.openUrl(method, uri);

      await Future.forEach(
        observers,
        (Observer observer) async => await observer.onRequest(httpRequest),
      );

      <String, dynamic>{
        if (json) ...{
          HttpHeaders.acceptHeader: ContentType.json.value,
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        },

        if (body != null) HttpHeaders.contentLengthHeader: bodyBytes.length,

        /// add shared headers
        ...this.headers,

        /// add extra headers
        ...?headers,
      }.forEach(httpRequest.headers.add);

      if (body != null) httpRequest.add(bodyBytes);

      if (logger)
        [
          'Request',
          '  URL: ${httpRequest.uri}',
          '  Method: ${httpRequest.method}',
          '  Headers: \n    ${httpRequest.headers.toString().split('\n').join('\n    ').trim()}',
          if (body != null)
            '  Preview: \n    ${converter.JsonEncoder.withIndent('  ')?.convert(body)?.split('\n')?.join('\n    ')?.trim() ?? body}',
        ].forEach(print);

      final httpResponse = await httpRequest.close();

      await Future.forEach(
        observers,
        (Observer observer) async => await observer.onResponse(httpResponse),
      );

      int sentBytes = 0;

      final response = Response(
        headers: httpResponse.headers,
        body: await httpResponse
            .transform(
              StreamTransformer.fromHandlers(
                handleData: (data, sink) {
                  sink.add(converter.utf8.decode(data));
                  sentBytes += data.length;
                  progress
                      ?.call(Progress(sentBytes, httpResponse.contentLength));
                },
                handleError: (error, stack, sink) async {
                  await Future.forEach(
                    observers,
                    (Observer observer) async =>
                        await observer.onError(Exception(error)),
                  );
                },
                handleDone: (sink) => sink.close(),
              ),
            )
            .join(),
        statusCode: httpResponse.statusCode,
      );

      if (logger)
        [
          'Response',
          if (httpRequest.connectionInfo?.remoteAddress?.host != null)
            '  Remote Address: ${httpResponse.connectionInfo.remoteAddress.host}',
          '  Status Code: ${response.isOk ? '🟢' : (response.isClientError ? '🟠' : '🔴')} ${response.statusCode} ${httpResponse.reasonPhrase}',
          '  Headers: \n    ${httpResponse.headers.toString().split('\n').join('\n    ')?.trim()}',
          '  Preview: \n    ${response.json != null ? converter.JsonEncoder.withIndent('  ')?.convert(response.json)?.split('\n')?.join('\n    ')?.trim() : response.body}',
        ].forEach(print);

      return response;
    } catch (error) {
      await Future.forEach(
        observers,
        (Observer observer) async => await observer.onError(Exception(error)),
      );

      return null;
    }
  }

  /// use [version] if you want to override version
  /// see [Uri.http] | [Uri.https]
  Uri _buildUri(String endpoint, String version, [Map<String, dynamic> query]) {
    final unencodedPath = [path, version ?? this.version, endpoint]
        .where((path) => path != null)
        .join('/');

    final queryParameters = query?.map((k, v) => MapEntry('$k', '$v'));

    final authority = '$host:${port ?? (secure ? 443 : 80)}';

    return secure
        ? Uri.https(authority, unencodedPath, queryParameters)
        : Uri.http(authority, unencodedPath, queryParameters);
  }
}
