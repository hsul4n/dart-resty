library resty;

import 'dart:convert' as converter;
import 'package:http/http.dart' as http;

class Resty {
  /// should use ssl
  final bool secure;

  /// see: [Uri.http] or [Uri.https]
  final String host;

  /// your base path
  final String path;

  /// api version if exists
  final String version;

  /// default headers
  final Map<String, dynamic> headers;

  const Resty({
    final this.secure = false,
    final String host,
    final int port,
    final this.path,
    final this.version,
    final this.headers = const {},
  })  : assert(secure != null),
        assert(host != null),
        assert(headers != null),
        this.host = '$host:${port == null ? secure ? '443' : '80' : port}';

  /// see [http.get]
  /// use [version] if you want to override version
  Future<http.Response> get(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic> query,
  }) async {
    return await http.get(
      _buildUri(endpoint, version, query),
      headers: _buildHeaders(headers),
    );
  }

  /// see [http.post]
  Future<http.Response> post(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    dynamic body,
  }) async {
    return await http.post(
      _buildUri(endpoint, version),
      headers: _buildHeaders(headers),
      body: _buildBody(body),
    );
  }

  /// see [http.put]
  Future<http.Response> put(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    dynamic body,
  }) async {
    return await http.put(
      _buildUri(endpoint, version),
      headers: _buildHeaders(headers),
      body: _buildBody(body),
    );
  }

  /// see [http.patch]
  Future<http.Response> patch(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    dynamic body,
  }) async {
    return await http.patch(
      _buildUri(endpoint, version),
      headers: _buildHeaders(headers),
      body: _buildBody(body),
    );
  }

  /// see [http.delete]
  Future<http.Response> delete(
    String endpoint, {
    String version,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic> query,
  }) async {
    return await http.delete(
      _buildUri(endpoint, version, query),
      headers: _buildHeaders(headers),
    );
  }

  /// see [Uri.http] | [Uri.https]
  Uri _buildUri(String endpoint, String version, [Map<String, dynamic> query]) {
    final unencodedPath = [path, version ?? this.version, endpoint]
        .where((p) => p != null)
        .join('/');

    final queryParameters = (query ?? {}).toStringValues();

    return secure
        ? Uri.https(host, unencodedPath, queryParameters)
        : Uri.http(host, unencodedPath, queryParameters);
  }

  Map<String, String> _buildHeaders(Map<String, dynamic> headers) =>
      {...this.headers, ...headers}.toStringValues();

  dynamic _buildBody(dynamic body) =>
      body is Map ? converter.json.encode(body) : body;
}

extension on Map {
  Map<String, String> toStringValues() =>
      this.map((key, value) => MapEntry(key, value.toString()));
}

extension RestyExtension on http.Response {
  bool get isSuccess => this.statusCode >= 200 && this.statusCode < 300;
  bool get isOk => this.isSuccess;
  bool get isRedirect => this.statusCode >= 300 && this.statusCode < 400;
  bool get isClientError => this.statusCode >= 400 && this.statusCode < 500;
  bool get isServerError => this.statusCode >= 500;

  dynamic get json =>
      converter.json.decode(converter.utf8.decode(this.bodyBytes));
}
