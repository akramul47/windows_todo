import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Utils/responsive_layout.dart';
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
            padding: ResponsiveLayout.responsivePadding(context),
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
                            style: TextStyle(
                              fontSize: ResponsiveLayout.responsiveFontSize(
                                context,
                                mobile: 18,
                                tablet: 20,
                                desktop: 22,
                              ),
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
                              // Capture references before showing snackbar
                              final todoList = context.read<TodoList>();
                              final todoId = todo.id;
                              
                              todoList.unarchiveTodo(todoId);

                              // Show centered snackbar
                              final deviceType = ResponsiveLayout.getDeviceType(context);
                              final isMobile = deviceType == DeviceType.mobile;
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.unarchive, color: Colors.white, size: 20),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Task unarchived',
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  width: isMobile ? null : 400,
                                  margin: isMobile ? const EdgeInsets.all(8) : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      // Use captured reference instead of context.read
                                      todoList.archiveTodo(todoId);
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
