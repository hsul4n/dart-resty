import 'dart:io';

import 'package:resty/resty.dart';
import 'package:test/test.dart';

void main() {
  group('test authentications', () {
    test('basic auth', () async {
      final resty = Resty(
        secure: true,
        auth: HttpClientBasicCredentials(
          'postman',
          'password',
        ),
        host: 'postman-echo.com',
        json: true,
      );

      final response = await resty.get('basic-auth');

      expect(response.isOk, true);
      expect(response.json, {'authenticated': true});
    });

    test('digest auth', () async {
      final resty = Resty(
        secure: true,
        auth: HttpClientDigestCredentials(
          'postman',
          'password',
        ),
        host: 'postman-echo.com',
        json: true,
      );

      final response = await resty.get('digest-auth');

      expect(response.isOk, true);
      expect(response.json, {'authenticated': true});
    });
  });
}
