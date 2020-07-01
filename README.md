# Resty

A simple http wrapper inspired from [zttp](https://github.com/kitetail/zttp) for dart and flutter.

# Features

- Simple use.
- One shared object.
- Support both dart & flutter.
- Depend on [http](https://pub.dev/packages/http) library.

# Usage

A simple example:

```dart
/// www.example.com/api/v1/
final resty = const Resty(
    host: 'www.example.com',
    path: 'api',
    version: 'v1',
);

/// www.example.com/api/v1/resources
final response = resty.get('resources', query: {
    'key': 'value',
});

/// true/false
if (response.isOk) {
    /// use [response.json] to auto convert response to json
    print(response.json);
}
```

# Resty ❤️ Flutter

You can use any service locator to access resty globally.
For this example we're using [get_it](https://pub.dev/packages/get_it).

```dart
// models/todo.dart
class Todo {
  final int id;
  final String title;
  final bool compeleted;

  Todo({this.id, this.title, this.compeleted});

  factory Todo.fromJson(Map<String, dynamic> item) => Todo(
        id: item['id'],
        title: item['title'],
        compeleted: item['completed'],
      );

  static List<Todo> fromJsonList(List<dynamic> items) =>
      items.map((item) => Todo.fromJson(item)).toList();
}

// services/todo_service.dart
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

// locator.dart
final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(
    () => const Resty(
        secure: true,
        host: 'jsonplaceholder.typicode.com',
        path: 'todos',
    ),
  );

  locator.registerLazySingleton(() => TodoService());
}
```

Then simply use

```dart
final todos = locator<TodoService>().all;
print('${todos.length} todos found!');
```

## Fututres & Bugs

Feature requests and bugs at the [issue tracker](https://github.com/hsul4n/dart-resty).
