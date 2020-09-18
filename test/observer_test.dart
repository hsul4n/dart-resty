import 'package:resty/resty.dart';
import 'package:test/test.dart';

void main() {
  final resty = Resty(
    secure: true,
    host: 'postman-echo.com',
    json: true,
    logger: true,
    observers: [
      Observer(
        onRequest: (request) {
          request.headers.add('foo', 'bar');
        },
      ),
    ],
  );

  test('Request', () async {
    final response = await resty.get('get');

    expect(response.json['headers']['foo'], 'bar');
  });
}
