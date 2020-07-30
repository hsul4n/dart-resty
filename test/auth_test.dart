import 'package:resty/resty.dart';
import 'package:test/test.dart';

void main() {
  final resty = const Resty(
    secure: true,
    auth: BasicAuth(
      username: 'postman',
      password: 'password',
    ),
    host: 'postman-echo.com',
    json: true,
  );

  group('test authentications', () {
    test('basic auth', () async {
      final response = await resty.get('basic-auth');

      expect(response.isOk, true);
      expect(response.json, {'authenticated': true});
    });
  });
}
