import 'package:example/locator.dart';
import 'package:example/models/todo.dart';
import 'package:resty/resty.dart';

class TodoService {
  final resty = locator<Resty>();

  Future<List<Todo>> get all async {
    final response = await resty.get('todos');

    if (response.isOk) return Todo.fromList(response.json);

    return [];
  }
}
