import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import '../Utils/app_theme.dart';
import '../models/todo.dart';
import '../models/todo_list.dart';
import '../services/storage_service.dart';
import '../widgets/add_task_field.dart';
import 'archives_screen.dart';
import '../widgets/glass_task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _textController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isWindowHovered = false;

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

  void _showUndoSnackBar(String message, VoidCallback onUndo) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        margin: const EdgeInsets.all(8),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: onUndo,
        ),
      ),
    );
  }

  Widget _buildTodoSection(
      String title, List<Todo> todos, TodoPriority priority) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                priority.icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.sectionHeaderStyle.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        DragTarget<Todo>(
          builder: (context, candidateData, rejectedData) {
            return Container(
              decoration: BoxDecoration(
                color: candidateData.isNotEmpty
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: todos
                    .map((todo) => _buildDraggableTask(todo, priority))
                    .toList(),
                onReorder: (oldIndex, newIndex) {
                  final todoList = context.read<TodoList>();
                  todoList.reorderTodo(priority, oldIndex, newIndex);
                  _saveTodos();
                },
              ),
            );
          },
          onAccept: (Todo todo) {
            final todoList = context.read<TodoList>();
            todoList.changeTodoPriority(todo.id, priority);
            _saveTodos();
          },
        ),
      ],
    );
  }

  Widget _buildDraggableTask(Todo todo, TodoPriority priority) {
    return LongPressDraggable<Todo>(
      key: ValueKey(todo.id),
      data: todo,
      feedback: Material(
        elevation: 4,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(todo.task, style: AppTheme.taskTextStyle),
        ),
      ),
      childWhenDragging: Container(
        color: Colors.transparent,
        height: 80,
      ),
      child: GlassTaskCard(
        todo: todo,
        isCompleted: false,
        onToggle: (todo) {
          context.read<TodoList>().toggleTodo(todo.id);
          _saveTodos();
        },
        onEdit: (todo, newTask) {
          context.read<TodoList>().editTodo(todo.id, newTask);
          _saveTodos();
        },
        onDelete: (todo) {
          context.read<TodoList>().deleteTodo(todo.id);
          _saveTodos();
          _showUndoSnackBar(
            'Task deleted',
            () {
              context
                  .read<TodoList>()
                  .addTodo(todo.task, priority: todo.priority);
              _saveTodos();
            },
          );
        },
        onArchive: (todo) {
          context.read<TodoList>().archiveTodo(todo.id);
          _saveTodos();
          _showUndoSnackBar(
            'Task archived',
            () {
              context.read<TodoList>().unarchiveTodo(todo.id);
              _saveTodos();
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildDraggableHeader(),
            Expanded(
              child: Consumer<TodoList>(
                builder: (context, todoList, child) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Text('Tasks', style: AppTheme.headerStyle),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.archive_outlined),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const ArchivesScreen(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return TaskAnimations.slideIn(
                                          animation, child);
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      AddTaskField(
                        controller: _textController,
                        onAdd: () {
                          if (_textController.text.isNotEmpty) {
                            context.read<TodoList>().addTodo(
                                _textController.text,
                                priority: TodoPriority.mainQuest);
                            _textController.clear();
                            _saveTodos();
                          }
                        },
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            context.read<TodoList>().addTodo(value,
                                priority: TodoPriority.mainQuest);
                            _textController.clear();
                            _saveTodos();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTodoSection('Main Quest', todoList.mainQuestTodos,
                          TodoPriority.mainQuest),
                      const SizedBox(height: 16),
                      _buildTodoSection('Side Quest', todoList.sideQuestTodos,
                          TodoPriority.sideQuest),
                      if (todoList.completedTodos.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Completed',
                          style: AppTheme.sectionHeaderStyle.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...todoList.completedTodos.map(
                          (todo) => GlassTaskCard(
                            todo: todo,
                            isCompleted: true,
                            onToggle: (todo) {
                              todoList.toggleTodo(todo.id);
                              _saveTodos();
                            },
                            onEdit: (todo, newTask) {
                              todoList.editTodo(todo.id, newTask);
                              _saveTodos();
                            },
                            onDelete: (todo) {
                              todoList.deleteTodo(todo.id);
                              _saveTodos();
                            },
                            onArchive: (todo) {
                              todoList.archiveTodo(todo.id);
                              _saveTodos();
                            },
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableHeader() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isWindowHovered = true),
      onExit: (_) => setState(() => _isWindowHovered = false),
      child: AnimatedOpacity(
        opacity: _isWindowHovered ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onPanStart: (details) {
            windowManager.startDragging();
          },
          child: Container(
            height: 32,
            color: AppTheme.glassBackgroundDarker,
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.drag_indicator,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Drag to move',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
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
