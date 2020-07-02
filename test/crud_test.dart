import 'package:resty/resty.dart';
import 'package:test/test.dart';

void main() {
  final resty = const Resty(
    secure: true,
    host: 'jsonplaceholder.typicode.com',
    headers: {
      'accept': 'application/json',
      'content-type': 'application/json',
    },
  );

  final todo = {
    'id': 1,
    'userId': 1,
    'title': 'Item 1',
    'completed': true,
  };

  group('test CRUD operations with extenstions', () {
    test('GET', () async {
      final response = await resty.get('todos');

      expect(response.json.length, 200);
      expect(response.isOk, true);
      expect(response.isClientError, false);
    });

    test('POST', () async {
      final response = await resty.post('todos', body: todo);

      expect(response.json, {
        ...todo,
        ...{'id': 201}
      });
      expect(response.isOk, true);
      expect(response.isClientError, false);
    });

    test('PUT', () async {
      final response = await resty.put('todos/${todo['id']}', body: todo);

      expect(response.json, todo);
      expect(response.isOk, true);
      expect(response.isClientError, false);
    });

    test('DELETE', () async {
      final response = await resty.delete('todos/${todo['id']}');

      expect(response.json, {});
      expect(response.isOk, true);
      expect(response.isClientError, false);
    });
  });
}
