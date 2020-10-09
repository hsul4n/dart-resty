import 'package:example/services/todo_service.dart';
import 'package:get_it/get_it.dart';
import 'package:resty/resty.dart';

final locator = GetIt.instance;

void setupLocator() {
  final resty = const Resty(
    secure: true,
    host: 'jsonplaceholder.typicode.com',
    logger: true,
  );

  // Resty
  locator.registerLazySingleton(() => resty);
  // Services
  locator.registerLazySingleton(() => TodoService());
}
