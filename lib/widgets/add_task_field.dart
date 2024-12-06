import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Utils/app_theme.dart';

class AddTaskField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  final ValueChanged<String> onSubmitted;

  const AddTaskField({
    Key? key,
    required this.controller,
    required this.onAdd,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.glassEffect,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.add_task,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Add a new task',
                hintStyle: GoogleFonts.inter(
                  color: Colors.black54,
                ),
                border: InputBorder.none,
              ),
              style: GoogleFonts.inter(
                fontSize: 16,
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
