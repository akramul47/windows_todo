import 'package:flutter/foundation.dart';

class Todo {
  String id;
  String task;
  bool isCompleted;
  DateTime createdAt;
  DateTime? completedAt;

  Todo({
    required this.id,
    required this.task,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  Todo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        task = json['task'],
        isCompleted = json['isCompleted'],
        createdAt = DateTime.parse(json['createdAt']),
        completedAt = json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'task': task,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };
}

class TodoList extends ChangeNotifier {
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;
  List<Todo> get activeTodos =>
      _todos.where((todo) => !todo.isCompleted).toList();
  List<Todo> get completedTodos =>
      _todos.where((todo) => todo.isCompleted).toList();

  void addTodo(String task) {
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      task: task,
      createdAt: DateTime.now(),
    );
    _todos.add(todo);
    notifyListeners();
  }

  void toggleTodo(String id) {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex].isCompleted = !_todos[todoIndex].isCompleted;
      _todos[todoIndex].completedAt =
          _todos[todoIndex].isCompleted ? DateTime.now() : null;
      notifyListeners();
    }
  }

  void setTodos(List<Todo> todos) {
    _todos = todos;
    notifyListeners();
  }
}
