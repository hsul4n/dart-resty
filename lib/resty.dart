library resty;

export 'src/auth/basic_auth.dart';
export 'src/response.dart';

import 'dart:io' show HttpClient, HttpHeaders, ContentType;
import 'dart:async' show Completer;
import 'dart:convert' as converter show utf8, json, JsonEncoder;

import 'package:resty/src/response.dart';
import 'package:resty/src/auth.dart';

class Resty {
  /// should use ssl
  final bool secure;

  /// use for auth headers
  final Auth auth;

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

  const Resty({
    final this.secure = false,
    final this.auth,
    final this.host,
    final this.port,
    final this.path,
    final this.headers = const {},
    final this.version,
    final this.json = false,
    final this.logger = false,
  })  : assert(secure != null),
        assert(host != null),
        assert(headers != null),
        assert(json != null),
        assert(logger != null);

  /// use [version] if you want to override version
  Future<Response> get(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic> query,
  }) async {
    return _open(
      method: 'GET',
      uri: _buildUri(endpoint, version, query),
      headers: headers,
    );
  }

  Future<Response> post(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    dynamic body,
  }) async {
    return _open(
      method: 'POST',
      uri: _buildUri(endpoint, version),
      headers: headers,
      body: body,
    );
  }

  Future<Response> put(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    dynamic body,
  }) async {
    return _open(
      method: 'PUT',
      uri: _buildUri(endpoint, version),
      headers: headers,
      body: body,
    );
  }

  Future<Response> patch(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    dynamic body,
  }) async {
    return _open(
      method: 'PATCH',
      uri: _buildUri(endpoint, version),
      headers: headers,
      body: body,
    );
  }

  Future<Response> delete(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic> query,
  }) {
    return _open(
      method: 'DELETE',
      uri: _buildUri(endpoint, version, query),
      headers: headers,
    );
  }

  Future<Response> _open({
    String method,
    Uri uri,
    Map<String, dynamic> headers,
    dynamic body,
  }) async {
    final httpRequest = await HttpClient().openUrl(method, uri);

    <String, dynamic>{
      ...this.headers,
      ...?headers,
      ...?auth?.header,
    }.forEach((key, value) {
      httpRequest.headers.add('$key', '$value');
    });

    if (json) {
      httpRequest.headers.add(HttpHeaders.acceptHeader, ContentType.json.value);
      httpRequest.headers.contentType = ContentType.json;
    }

    if (body != null) httpRequest.write(converter.json.encode(body));

    if (logger)
      [
        'Request',
        '  URL: ${httpRequest.uri}',
        '  Method: ${httpRequest.method}',
        '  Headers: \n    ${httpRequest.headers.toString().split('\n').join('\n    ').trim()}',
      ].forEach(print);

    final httpResponse = await httpRequest.close();

    final completer = Completer<String>();
    final contents = StringBuffer();
    httpResponse.transform(converter.utf8.decoder).listen(
          contents.write,
          onDone: () => completer.complete(contents.toString()),
        );

    final response = Response(
      statusCode: httpResponse.statusCode,
      body: await completer.future,
    );

    if (logger)
      [
        'Response',
        '  Remote Address: ${httpResponse.connectionInfo.remoteAddress.host}',
        '  Status Code: ${response.isOk ? '🟢' : (response.isClientError ? '🟠' : '🔴')} ${response.statusCode} ${httpResponse.reasonPhrase}',
        '  Headers: \n    ${httpResponse.headers.toString().split('\n').join('\n    ')?.trim()}',
        '  Preview: \n    ${converter.JsonEncoder.withIndent('  ').convert(response.json ?? response.body)?.split('\n')?.join('\n    ')?.trim()}',
      ].forEach(print);

    return response;
  }

  /// see [Uri.http] | [Uri.https]
  Uri _buildUri(String endpoint, String version, [Map<String, dynamic> query]) {
    final unencodedPath = [path, version ?? this.version, endpoint]
        .where((p) => p != null)
        .join('/');

    final queryParameters = (query ?? {})
        .map<String, String>((key, value) => MapEntry('$key', '$value'));

    final authority = '$host:${port ?? (secure ? 443 : 80)}';

    return secure
        ? Uri.https(authority, unencodedPath, queryParameters)
        : Uri.http(authority, unencodedPath, queryParameters);
  }
}
