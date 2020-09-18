class Todo {
  final int id;
  final String title;
  final bool compeleted;

  Todo({this.id, this.title, this.compeleted});

  Todo.fromJson(Map<String, dynamic> item)
      : id = item['id'],
        title = item['title'],
        compeleted = item['completed'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'compeleted': compeleted ? 1 : 0,
      };

  static List<Todo> fromList(List<dynamic> items) =>
      items.map((item) => Todo.fromJson(item)).toList();
}
