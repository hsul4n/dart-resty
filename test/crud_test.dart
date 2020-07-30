import 'package:resty/resty.dart';
import 'package:test/test.dart';

void main() {
  final resty = const Resty(
    secure: true,
    host: 'postman-echo.com',
    json: true,
  );

  final data = {'foo': 'bar'};

  group('test CRUD operations', () {
    test('GET', () async {
      final response = await resty.get('get', query: data);

      expect(response.json['args'], data);
    });

    test('POST', () async {
      final response = await resty.post('post', body: data);

      expect(response.json['data'], data);
    });

    test('PUT', () async {
      final response = await resty.put('put', body: data);

      expect(response.json['data'], data);
    });

    test('DELETE', () async {
      final response = await resty.delete('delete', query: data);

      expect(response.json['args'], data);
    });
  });
}
