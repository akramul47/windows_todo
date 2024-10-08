import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windows_todo/models/todo.dart';

class StorageService {
  static const String _todosKey = 'todos';

  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final String todosJson = json.encode(
      todos.map((todo) => todo.toJson()).toList(),
    );
    await prefs.setString(_todosKey, todosJson);
  }

  Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString(_todosKey);
    if (todosJson == null) return [];

    final List<dynamic> todosList = json.decode(todosJson);
    return todosList.map((json) => Todo.fromJson(json)).toList();
  }

  Future<void> archiveCompletedTasks(List<Todo> completedTodos) async {
    final directory = await getApplicationDocumentsDirectory();
    final archiveDir = Directory('${directory.path}/todo_archives');
    if (!await archiveDir.exists()) {
      await archiveDir.create(recursive: true);
    }

    final date = DateTime.now();
    final fileName = '${date.year}-${date.month}-${date.day}.json';
    final file = File('${archiveDir.path}/$fileName');

    final archiveData = {
      'date': date.toIso8601String(),
      'tasks': completedTodos.map((todo) => todo.toJson()).toList(),
    };

    await file.writeAsString(json.encode(archiveData));
  }

  Future<Map<String, List<Todo>>> loadArchivedTasks() async {
    final directory = await getApplicationDocumentsDirectory();
    final archiveDir = Directory('${directory.path}/todo_archives');
    if (!await archiveDir.exists()) {
      return {};
    }

    final Map<String, List<Todo>> archives = {};
    final List<FileSystemEntity> files = await archiveDir.list().toList();

    for (var file in files) {
      if (file is File && file.path.endsWith('.json')) {
        final content = await file.readAsString();
        final data = json.decode(content);
        final tasks =
            (data['tasks'] as List).map((task) => Todo.fromJson(task)).toList();
        archives[data['date']] = tasks;
      }
    }

    return archives;
  }
}
