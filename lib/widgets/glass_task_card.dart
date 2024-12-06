import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/app_theme.dart';
import '../models/todo.dart';

class GlassTaskCard extends StatefulWidget {
  final Todo todo;
  final bool isCompleted;
  final Function(Todo) onToggle;
  final Function(Todo, String) onEdit;
  final Function(Todo) onDelete;
  final Function(Todo) onArchive;
  final VoidCallback? onTap;

  const GlassTaskCard({
    Key? key,
    required this.todo,
    required this.isCompleted,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onArchive,
    this.onTap,
  }) : super(key: key);

  @override
  _GlassTaskCardState createState() => _GlassTaskCardState();
}

class _GlassTaskCardState extends State<GlassTaskCard> {
  bool _isEditing = false;
  late TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.todo.task);
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _finishEditing() {
    if (_editingController.text.trim().isNotEmpty) {
      widget.onEdit(widget.todo, _editingController.text.trim());
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.todo.id),
      background:
          _buildDismissibleBackground(context, DismissDirection.startToEnd),
      secondaryBackground:
          _buildDismissibleBackground(context, DismissDirection.endToStart),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          widget.onDelete(widget.todo);
        } else {
          widget.onArchive(widget.todo);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: AppTheme.taskCardEffect,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isEditing ? null : _startEditing,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildCheckbox(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _isEditing
                        ? TextField(
                            controller: _editingController,
                            autofocus: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Edit task',
                              hintStyle: AppTheme.taskTextStyle.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                            style: AppTheme.taskTextStyle.copyWith(
                              decoration: widget.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: widget.isCompleted
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                            onSubmitted: (_) => _finishEditing(),
                            onEditingComplete: _finishEditing,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.todo.task,
                                style: AppTheme.taskTextStyle.copyWith(
                                  decoration: widget.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: widget.isCompleted
                                      ? Colors.grey
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    widget.todo.priority.icon,
                                    size: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.todo.priority.displayName,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  // if (!_isEditing && !widget.isCompleted)
                  //   IconButton(
                  //     icon: const Icon(Icons.edit_outlined, size: 20),
                  //     onPressed: _startEditing,
                  //     color: Theme.of(context).colorScheme.outline,
                  //   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return InkWell(
      onTap: () => widget.onToggle(widget.todo),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isCompleted
              ? Colors.green.withOpacity(0.9)
              : Colors.transparent,
          border: Border.all(
            color: widget.isCompleted
                ? Colors.transparent
                : Colors.grey.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: widget.isCompleted
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildDismissibleBackground(
      BuildContext context, DismissDirection direction) {
    final isDeleteAction = direction == DismissDirection.endToStart;
    return Container(
      alignment: isDeleteAction ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: isDeleteAction ? Colors.red : Colors.orange,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDeleteAction ? Icons.delete : Icons.archive,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            isDeleteAction ? 'Delete' : 'Archive',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
