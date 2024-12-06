import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SystemTrayService {
  static const String _tooltipMessage = 'Windows Todo';

  static Future<String> _getIconPath() async {
    final ByteData data = await rootBundle.load('assets/app_icon.ico');
    final Directory tempDir = await getTemporaryDirectory();
    final String iconPath = '${tempDir.path}/app_icon.ico';

    final File iconFile = File(iconPath);
    await iconFile.writeAsBytes(data.buffer.asUint8List());

    return iconPath;
  }

  static Future<void> initSystemTray() async {
    final String iconPath = await _getIconPath();

    await trayManager.setIcon(
      iconPath,
      isTemplate: true,
    );

    await trayManager.setToolTip(_tooltipMessage);

    final Menu menu = Menu(
      items: [
        MenuItem(
          label: 'Show',
          onClick: (menuItem) async {
            await windowManager.show();
          },
        ),
        MenuItem(
          label: 'Hide',
          onClick: (menuItem) async {
            await windowManager.hide();
          },
        ),
        MenuItem.separator(),
        MenuItem(
          label: 'Exit',
          onClick: (menuItem) async {
            await windowManager.close();
          },
        ),
      ],
    );

    await trayManager.setContextMenu(menu);
  }
}
