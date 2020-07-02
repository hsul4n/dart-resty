import 'package:example/services/todo_service.dart';
import 'package:get_it/get_it.dart';
import 'package:resty/resty.dart';

final locator = GetIt.instance;

void setupLocator() {
  // jsonplaceholder.typicode.com/api/v3
  const resty = const Resty(
    host: 'jsonplaceholder.typicode.com',
    path: 'api',
    version: 'v1',
    secure: true,
    // versions: ['v1', 'v2', 'v3'],
  );

  locator.registerLazySingleton(() => resty);
  locator.registerLazySingleton(() => TodoService());
}
