import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:windows_todo/models/todo.dart';
import 'package:windows_todo/services/storage_service.dart';
import 'package:windows_todo/screens/archives_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _textController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final storageService = context.read<StorageService>();
    final todoList = context.read<TodoList>();
    final todos = await storageService.loadTodos();
    todoList.setTodos(todos);
  }

  Future<void> _saveTodos() async {
    final storageService = context.read<StorageService>();
    final todoList = context.read<TodoList>();
    await storageService.saveTodos(todoList.todos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ArchivesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Add a new task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        context.read<TodoList>().addTodo(value);
                        _textController.clear();
                        _saveTodos();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      context.read<TodoList>().addTodo(_textController.text);
                      _textController.clear();
                      _saveTodos();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TodoList>(
              builder: (context, todoList, child) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...todoList.activeTodos.map(
                      (todo) => _buildTodoItem(todo, false),
                    ),
                    if (todoList.completedTodos.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...todoList.completedTodos.map(
                        (todo) => _buildTodoItem(todo, true),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(Todo todo, bool isCompleted) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            todo.isCompleted
                ? Icons.check_circle
                : Icons.check_circle_outline,
            color: todo.isCompleted ? Colors.green : Colors.grey,
          ),
          onPressed: () {
            context.read<TodoList>().toggleTodo(todo.id);
            _saveTodos();
          },
        ),
        title: Text(
          todo.task,
          style: TextStyle(
            decoration: todo.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}