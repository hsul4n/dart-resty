import 'package:example/locator.dart';
import 'package:example/models/todo.dart';
import 'package:resty/resty.dart';

class TodoService {
  final api = locator<Resty>();

  Future<List<Todo>> get all async {
    final response = await api.get('todos');

    if (response.isOk) {
      return Todo.fromJsonList(response.json);
    }

    return [];
  }
}
