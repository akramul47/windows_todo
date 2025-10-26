import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_todo/Utils/app_theme.dart';
import 'package:windows_todo/providers/theme_provider.dart';
import 'package:windows_todo/screens/home_screen.dart';
import 'package:windows_todo/services/storage_service.dart';
import 'package:windows_todo/services/windows_service.dart';

import 'models/todo_list.dart';

// Platform detection helpers
bool get isWindows => !kIsWeb && Platform.isWindows;
bool get isDesktopPlatform => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Note: System UI overlay will be configured dynamically based on theme in MaterialApp
  // This ensures proper status bar colors for both light and dark modes
  
  // Enable edge-to-edge mode for mobile
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }
  
  // Only configure window manager on desktop platforms
  if (isDesktopPlatform) {
    try {
      await WindowManager.instance.ensureInitialized();

      // Load saved window state
      final storageService = StorageService();
      final windowState = await storageService.loadWindowState();

      // Configure window properties for desktop
      await windowManager.waitUntilReadyToShow().then((_) async {
        // Set minimum size
        await windowManager.setMinimumSize(const Size(350, 500));
        
        if (isWindows) {
          // Restore saved state or use defaults for Windows
          if (windowState != null) {
            await windowManager.setSize(Size(
              windowState['width'] as double,
              windowState['height'] as double,
            ));
            if (windowState['x'] != null && windowState['y'] != null) {
              await windowManager.setPosition(Offset(
                windowState['x'] as double,
                windowState['y'] as double,
              ));
            }
            await windowManager.setAlwaysOnTop(windowState['isAlwaysOnTop'] as bool);
            if (windowState['isMaximized'] as bool) {
              await windowManager.maximize();
            }
          } else {
            // Default Windows settings (sidebar mode)
            await windowManager.setSize(const Size(400, 700));
            await windowManager.setAlwaysOnTop(true);
          }
          // Windows-specific settings
          await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
          await windowManager.setBackgroundColor(Colors.transparent);
        } else {
          // macOS/Linux
          if (windowState != null) {
            await windowManager.setSize(Size(
              windowState['width'] as double,
              windowState['height'] as double,
            ));
            if (windowState['x'] != null && windowState['y'] != null) {
              await windowManager.setPosition(Offset(
                windowState['x'] as double,
                windowState['y'] as double,
              ));
            }
            if (windowState['isMaximized'] as bool) {
              await windowManager.maximize();
            }
          } else {
            // Default size for macOS/Linux
            await windowManager.setSize(const Size(900, 700));
          }
        }
        
        // Set window to be resizable
        await windowManager.setResizable(true);
        await windowManager.show();
      });

      // Setup auto-start only on Windows
      if (isWindows) {
        await WindowsService.setupAutoStart();
      }
    } catch (e) {
      debugPrint('Window manager initialization failed: $e');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoList()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider(create: (_) => StorageService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Get effective brightness
          final brightness = themeProvider.effectiveThemeMode == ThemeMode.dark
              ? Brightness.dark
              : themeProvider.effectiveThemeMode == ThemeMode.light
                  ? Brightness.light
                  : MediaQuery.platformBrightnessOf(context);

          // Update system UI overlay style for mobile based on theme
          if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
            final isDark = brightness == Brightness.dark;
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
                systemNavigationBarColor: isDark ? const Color(0xFF000000) : Colors.white,
                systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                systemNavigationBarDividerColor: Colors.transparent,
              ),
            );
          }

          return MaterialApp(
            title: 'Quest',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.effectiveThemeMode,
            home: isWindows
                ? const WindowFrame(child: HomeScreen())
                : const HomeScreen(),
          );
        },
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
  bool _isHeaderHovered = false; // Track if header is hovered
  bool _isAlwaysOnTop = true; // Track always-on-top state
  bool _isMaximized = false; // Track maximized state
  Size? _previousSize; // Store previous size for restore
  Offset? _previousPosition; // Store previous position for restore

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _loadWindowState();
  }

  // Load initial window state
  Future<void> _loadWindowState() async {
    try {
      final isMaximized = await windowManager.isMaximized();
      final isAlwaysOnTop = await windowManager.isAlwaysOnTop();
      setState(() {
        _isMaximized = isMaximized;
        _isAlwaysOnTop = isAlwaysOnTop;
      });
    } catch (e) {
      debugPrint('Failed to load window state: $e');
    }
  }

  // Save window state
  Future<void> _saveWindowState() async {
    try {
      final size = await windowManager.getSize();
      final position = await windowManager.getPosition();
      final storageService = StorageService();
      await storageService.saveWindowState(
        width: size.width,
        height: size.height,
        x: position.dx,
        y: position.dy,
        isMaximized: _isMaximized,
        isAlwaysOnTop: _isAlwaysOnTop,
      );
    } catch (e) {
      debugPrint('Failed to save window state: $e');
    }
  }

  // Toggle always on top
  Future<void> _toggleAlwaysOnTop() async {
    try {
      setState(() {
        _isAlwaysOnTop = !_isAlwaysOnTop;
      });
      await windowManager.setAlwaysOnTop(_isAlwaysOnTop);
      await _saveWindowState();
    } catch (e) {
      debugPrint('Failed to toggle always on top: $e');
    }
  }

  // Toggle maximize/restore
  Future<void> _toggleMaximize() async {
    try {
      if (_isMaximized) {
        // Restore to previous size and position
        if (_previousSize != null && _previousPosition != null) {
          await windowManager.unmaximize();
          // Small delay to ensure unmaximize completes
          await Future.delayed(const Duration(milliseconds: 50));
          await windowManager.setSize(_previousSize!);
          await windowManager.setPosition(_previousPosition!);
          setState(() {
            _isMaximized = false;
          });
        } else {
          // Fallback if no previous state
          await windowManager.unmaximize();
          setState(() {
            _isMaximized = false;
          });
        }
      } else {
        // Save current size and position before maximizing
        _previousSize = await windowManager.getSize();
        _previousPosition = await windowManager.getPosition();
        await windowManager.maximize();
        setState(() {
          _isMaximized = true;
        });
      }
      await _saveWindowState();
    } catch (e) {
      debugPrint('Failed to toggle maximize: $e');
    }
  }

  @override
  void onWindowResize() {
    super.onWindowResize();
    // Save current size as previous size when not maximized
    if (!_isMaximized) {
      _updatePreviousState();
    }
    _saveWindowState();
  }

  @override
  void onWindowMove() {
    super.onWindowMove();
    // Save current position as previous position when not maximized
    if (!_isMaximized) {
      _updatePreviousState();
    }
    _saveWindowState();
  }

  // Update previous state with current window state
  Future<void> _updatePreviousState() async {
    try {
      _previousSize = await windowManager.getSize();
      _previousPosition = await windowManager.getPosition();
    } catch (e) {
      debugPrint('Failed to update previous state: $e');
    }
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    setState(() {
      _isMaximized = true;
    });
    _saveWindowState();
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    setState(() {
      _isMaximized = false;
    });
    _saveWindowState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF000000).withOpacity(0.98)
              : Theme.of(context).colorScheme.background.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Only show draggable header on Windows - hidden until hovered
            if (isWindows)
              AnimatedOpacity(
                opacity: _isHovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHeaderHovered = true),
                  onExit: (_) => setState(() => _isHeaderHovered = false),
                  child: GestureDetector(
                    onPanStart: (details) {
                      try {
                        windowManager.startDragging();
                      } catch (e) {
                        debugPrint('Failed to start dragging: $e');
                      }
                    },
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.primaryColorDark.withOpacity(0.1)
                            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Drag indicator
                          Icon(
                            Icons.drag_indicator,
                            size: 20,
                            color: isDark
                                ? AppTheme.primaryColorDark
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          // "Drag to move" text - only shows when hovering over header
                          if (_isHeaderHovered)
                            Expanded(
                              child: Text(
                                'Drag to move',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppTheme.primaryColorDark
                                      : Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (!_isHeaderHovered)
                            const Spacer(),
                          // Always on top toggle button
                          IconButton(
                          icon: Icon(
                            _isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined,
                            size: 18,
                            color: _isAlwaysOnTop
                                ? (isDark
                                    ? AppTheme.primaryColorDark
                                    : Theme.of(context).colorScheme.primary)
                                : (isDark
                                    ? AppTheme.primaryColorDark.withOpacity(0.6)
                                    : Theme.of(context).colorScheme.primary.withOpacity(0.6)),
                          ),
                          onPressed: _toggleAlwaysOnTop,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: _isAlwaysOnTop ? 'Unpin window' : 'Pin window on top',
                        ),
                        const SizedBox(width: 8),
                        // Minimize button
                        IconButton(
                          icon: Icon(
                            Icons.remove,
                            size: 18,
                            color: isDark
                                ? AppTheme.primaryColorDark
                                : Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            try {
                              windowManager.minimize();
                            } catch (e) {
                              debugPrint('Failed to minimize: $e');
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Minimize',
                        ),
                        const SizedBox(width: 8),
                        // Maximize/Restore button
                        IconButton(
                          icon: Icon(
                            _isMaximized ? Icons.fullscreen_exit : Icons.fullscreen,
                            size: 18,
                            color: isDark
                                ? AppTheme.primaryColorDark
                                : Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: _toggleMaximize,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: _isMaximized ? 'Restore' : 'Maximize',
                        ),
                        const SizedBox(width: 8),
                        // Close button
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: isDark
                                ? AppTheme.primaryColorDark
                                : Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            try {
                              windowManager.hide();
                            } catch (e) {
                              debugPrint('Failed to hide: $e');
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
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
