import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../models/todo_list.dart';

class ArchivesScreen extends StatefulWidget {
  const ArchivesScreen({super.key});

  @override
  State<ArchivesScreen> createState() => _ArchivesScreenState();
}

class _ArchivesScreenState extends State<ArchivesScreen> {
  Map<String, List<Todo>> _groupArchivedTodos(List<Todo> archivedTodos) {
    final Map<String, List<Todo>> grouped = {};

    for (var todo in archivedTodos) {
      // Use completedAt date if available, otherwise use createdAt
      final date = todo.completedAt ?? todo.createdAt;
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(todo);
    }

    // Sort the map keys in reverse chronological order
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archives'),
        elevation: 0,
      ),
      body: Consumer<TodoList>(
        builder: (context, todoList, child) {
          final archivedTodos = todoList.archivedTodos;

          if (archivedTodos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No archived tasks',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final groupedTodos = _groupArchivedTodos(archivedTodos);

          return ListView.builder(
            itemCount: groupedTodos.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final dateKey = groupedTodos.keys.elementAt(index);
              final tasks = groupedTodos[dateKey]!;
              final date = DateTime.parse(dateKey);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            DateFormat.yMMMMd().format(date),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${tasks.length} ${tasks.length == 1 ? 'task' : 'tasks'}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (context, taskIndex) {
                        final todo = tasks[taskIndex];
                        return ListTile(
                          leading: Icon(
                            todo.priority.icon,
                            color: todo.isCompleted
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            todo.task,
                            style: TextStyle(
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            todo.priority.displayName,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.unarchive),
                            onPressed: () {
                              context.read<TodoList>().unarchiveTodo(todo.id);

                              // Show snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Task unarchived'),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(8),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: () {
                                      context
                                          .read<TodoList>()
                                          .archiveTodo(todo.id);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
