import 'package:resty/resty.dart';

void main(List<String> arguments) async {
  final resty = const Resty(
    // secure: true,
    host: 'www.googleapis.com',
    path: 'books',
    version: 'v1',
  );

  final response = await resty.get('volumes', query: {'q': '{rest}'});

  if (response.isOk) {
    final itemCount = response.json['totalItems'];
    print('Number of books about rest: $itemCount.');
  }
}
