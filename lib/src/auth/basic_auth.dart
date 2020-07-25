import 'dart:convert' show base64, utf8;

import '../auth.dart';

class BasicAuth implements Auth {
  final String username;
  final String password;

  Map<String, String> get header => {
        'authorization':
            'Basic ${base64.encode(utf8.encode('$username:$password'))}'
      };

  const BasicAuth({this.username, this.password});
}
