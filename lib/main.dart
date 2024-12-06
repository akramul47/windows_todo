import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_todo/Utils/app_theme.dart';
import 'package:windows_todo/screens/home_screen.dart';
import 'package:windows_todo/services/storage_service.dart';
import 'package:windows_todo/services/windows_service.dart';

import 'models/todo_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManager.instance.ensureInitialized();

  // Configure window properties
  await windowManager.waitUntilReadyToShow().then((_) async {
    // Set minimum size
    await windowManager.setMinimumSize(const Size(300, 400));
    // Set initial size
    await windowManager.setSize(const Size(350, 600));
    // Set always on top
    await windowManager.setAlwaysOnTop(true);
    // Remove window title bar
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    // Make window transparent
    await windowManager.setBackgroundColor(Colors.transparent);
    // Set window to be borderless
    await windowManager.setResizable(true);
    await windowManager.show();
  });

  await WindowsService.setupAutoStart();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoList()),
        Provider(create: (_) => StorageService()),
      ],
      child: MaterialApp(
        title: 'Quest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const WindowFrame(child: HomeScreen()),
      ),
    );
  }
}

class WindowFrame extends StatefulWidget {
  final Widget child;

  const WindowFrame({super.key, required this.child});

  @override
  State<WindowFrame> createState() => _WindowFrameState();
}

class _WindowFrameState extends State<WindowFrame> with WindowListener {
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onPanStart: (details) {
                windowManager.startDragging();
              },
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: () => windowManager.minimize(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => windowManager.hide(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}
