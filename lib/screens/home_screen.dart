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
  bool _isDragging = false;
  TodoPriority? _draggingFromPriority;

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
          padding: const EdgeInsets.only(bottom: 8),
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
            final bool isHovering = candidateData.isNotEmpty && 
                candidateData.first?.priority != priority;
            final bool showDropZone = _isDragging && 
                _draggingFromPriority != null &&
                _draggingFromPriority != priority;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 0),
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: isHovering
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : showDropZone
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHovering
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
                      : showDropZone
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                          : Colors.transparent,
                  width: isHovering ? 2.5 : showDropZone ? 2 : 0,
                ),
              ),
              child: Column(
                children: [
                  // Show drop zone message when dragging from another section
                  if (showDropZone)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        color: isHovering
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(
                            isHovering ? 0.4 : 0.2
                          ),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isHovering ? 'Release to add here' : 'Drag here to add to $title',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isHovering ? FontWeight.w600 : FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary.withOpacity(
                              isHovering ? 1 : 0.7
                            ),
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  // Show tasks
                  if (todos.isNotEmpty)
                    Column(
                      children: todos
                          .map((todo) => _buildDraggableTask(todo, priority))
                          .toList(),
                    ),
                ],
              ),
            );
          },
          onWillAccept: (data) => data != null && data.priority != priority,
          onAccept: (Todo todo) {
            setState(() {
              _isDragging = false;
              _draggingFromPriority = null;
            });
            final todoList = context.read<TodoList>();
            todoList.changeTodoPriority(todo.id, priority);
            _saveTodos();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Moved to $title',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green.shade700,
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          onLeave: (data) {
            // Optional: could add feedback when leaving drop zone
          },
        ),
      ],
    );
  }

  Widget _buildDraggableTask(Todo todo, TodoPriority priority) {
    return DragTarget<Todo>(
      key: ValueKey(todo.id),
      onWillAccept: (data) => data != null && data.id != todo.id,
      onAccept: (draggedTodo) {
        setState(() {
          _isDragging = false;
          _draggingFromPriority = null;
        });
        final todoList = context.read<TodoList>();
        if (draggedTodo.priority == priority) {
          // Reordering within the same section
          final todos = priority == TodoPriority.mainQuest
              ? todoList.mainQuestTodos
              : todoList.sideQuestTodos;
          final oldIndex = todos.indexWhere((t) => t.id == draggedTodo.id);
          final newIndex = todos.indexWhere((t) => t.id == todo.id);
          if (oldIndex != -1 && newIndex != -1) {
            todoList.reorderTodo(priority, oldIndex, newIndex);
            _saveTodos();
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Column(
          children: [
            if (isHovering && candidateData.first?.priority == priority)
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            LongPressDraggable<Todo>(
              data: todo,
              delay: const Duration(milliseconds: 300),
              hapticFeedbackOnStart: true,
              onDragStarted: () {
                setState(() {
                  _isDragging = true;
                  _draggingFromPriority = priority;
                });
              },
              onDragEnd: (details) {
                setState(() {
                  _isDragging = false;
                  _draggingFromPriority = null;
                });
              },
              onDraggableCanceled: (velocity, offset) {
                setState(() {
                  _isDragging = false;
                  _draggingFromPriority = null;
                });
              },
              feedback: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(12),
                shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).cardColor,
                        Theme.of(context).cardColor.withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.drag_indicator,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          todo.task,
                          style: AppTheme.taskTextStyle.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.2,
                child: GlassTaskCard(
                  todo: todo,
                  isCompleted: false,
                  onToggle: (todo) {},
                  onEdit: (todo, newTask) {},
                  onDelete: (todo) {},
                  onArchive: (todo) {},
                ),
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
            ),
          ],
        );
      },
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
                            Text('Quest', style: AppTheme.headerStyle),
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
