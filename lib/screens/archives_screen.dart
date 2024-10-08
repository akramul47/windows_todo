import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:windows_todo/models/todo.dart';
import 'package:windows_todo/services/storage_service.dart';

class ArchivesScreen extends StatefulWidget {
  const ArchivesScreen({super.key});

  @override
  State<ArchivesScreen> createState() => _ArchivesScreenState();
}

class _ArchivesScreenState extends State<ArchivesScreen> {
  Map<String, List<Todo>> _archives = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArchives();
  }

  Future<void> _loadArchives() async {
    final storageService = context.read<StorageService>();
    final archives = await storageService.loadArchivedTasks();
    setState(() {
      _archives = archives;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archives'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _archives.isEmpty
              ? const Center(child: Text('No archived tasks'))
              : ListView.builder(
                  itemCount: _archives.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final date = DateTime.parse(
                      _archives.keys.elementAt(index),
                    );
                    final tasks = _archives.values.elementAt(index);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              DateFormat.yMMMMd().format(date),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: tasks.length,
                            itemBuilder: (context, taskIndex) {
                              final todo = tasks[taskIndex];
                              return ListTile(
                                leading: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                title: Text(
                                  todo.task,
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}