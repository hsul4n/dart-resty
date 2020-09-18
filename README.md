A simple, light and useful http wrapper inspired from [zttp](https://github.com/kitetail/zttp) for dart and flutter.

# Features

- 📦 Lightweight.
- 🚀 Simple use.
- ✅ Support both dart & flutter.

# Usage

## Request

```dart
// https://www.example.com:3000/api/v1/
final resty = Resty(
    /// true:https (default if certificate is passed) | false:http (default)
    secure: true,
    /// load certificate
    certificate: await rootBundle.load("assets/certificate.crt"),
    /// base-url without http
    host: 'www.example.com',
    /// secure:443 | not-secure:80 (default)
    port: 3000,
    /// base path
    path: 'api',
    /// you can override later in any request
    version: 'v1',
    /// use to set accept & content-type to `application/json`
    json: true,
    /// use to enable logger
    logger: true,
    /// use to send shared headers
    headers: {
      'foo': 'bar',
    },
    /// use to specify timeout (default: 30 sec)
    timeout: Duration(seconds: 60),
    /// listen to request, response and also errors
    observers: [
      Observer(
        onRequest: (request) async {
          /// always pass your token before sending request to server
          request.headers.add('Authorization', 'Bearer ${YOUR_TOKEN_HERE}');
        },
        onResponse: (response) {
          // TODO
        },
        onError: (exception) {
          // TODO
        },
      ),
    ],
);

// It as simple as
// https://www.example.com:3000/api/v1/resources
resty.get('resources', query: {'foo': 'bar'});

// you can override your api version whenever you want
// https://www.example.com:3000/api/v2/resources
resty.get('resources', version: 'v2');
```

## Response

```dart
final response = await resty.get('resources');

// status code between 200 & 300
response.isOk | response.isSuccess

// status code between 300 & 400
response.isRedirect

// status code between 400 & 500
response.isClientError

// status code >= 500
response.isServerError

// get body
response.body

// auto convert body to json
response.json
```

# Authentication

## Basic Auth

```dart
final resty = Resty(
  // ...
  secure: true,
  auth: HttpClientBasicCredentials(
    'postman', // username
    'password', // password
  ),
  // ...
);
```

## Digest Auth

```dart
final resty = Resty(
  // ...
  secure: true,
  auth: HttpClientDigestCredentials(
    'postman', // username
    'password', // password
  ),
  // ...
);
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

  Todo.fromMap(Map<String, dynamic> item)
      : id = item['id'],
        title = item['title'],
        compeleted = item['completed'];

  static List<Todo> fromList(List<dynamic> items) =>
      items.map((item) => Todo.fromMap(item)).toList();
}

// services/todo_service.dart
class TodoService {
  final resty = locator<Resty>();

  Future<List<Todo>> get all async {
    final response = await resty.get('todos');

    if (response.isOk) {
      return Todo.fromList(response.json);
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
    ),
  );

  locator.registerLazySingleton(() => resty);
  locator.registerLazySingleton(() => TodoService());
}
```

Then simply use

```dart
setupLocator();
final todos = locator<TodoService>().all;
print('${todos.length} todos found!');
```

Check full [example](https://github.com/hsul4n/dart-resty/tree/master/example/flutter)
