import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:fclash/core/clash/clash_controller.dart';
import 'package:fclash/core/core_providers.dart';
import 'package:fclash/core/prefs/locale/locale.dart';
import 'package:fclash/domain/models/clash_proxy_group.dart';
import 'package:fclash/services/notification/notification.dart';
import 'package:fclash/services/service_providers.dart';
import 'package:fclash/utils/utils.dart';
import 'package:tray_manager/tray_manager.dart';

enum SystemTrayAction {
  setSystemProxy('assr'),
  unsetSystemProxy('ausr'),
  showApp('show'),
  exitApp('exit');

  const SystemTrayAction(this.key);

  factory SystemTrayAction.fromKey(String key) {
    return SystemTrayAction.values.firstOrNullWhere((e) => e.key == key) ??
        exitApp;
  }

  final String key;

  String translation(TranslationsEn t) {
    switch (this) {
      case showApp:
        return t.tray.showApp;
      case exitApp:
        return t.tray.exitApp;
      case setSystemProxy:
        return t.tray.setSystemProxy;
      case unsetSystemProxy:
        return t.tray.clearSystemProxy;
    }
  }
}

mixin ClashPlatformCoordinator on ClashController
    implements TrayListener, LoggerMixin {
  NotificationService get _notification => ref.read(Services.notification);
  TranslationsEn get _t => ref.read(Core.translations);

  Future<void> startCoordination() async {
    loggy.debug('tray: starting platform coordination');
    await setupSystemTray(null);
    trayManager.addListener(this);
    await _notification.showNotification(id: 0, title: 'service is running');
  }

  Future<void> setupSystemTray(List<MenuItem>? menuItems) async {
    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/images/app_tray.ico'
          : 'assets/images/app_tray.png',
    );
    final List<MenuItem> items = [
      MenuItem(
        key: SystemTrayAction.showApp.key,
        label: SystemTrayAction.showApp.translation(_t),
      ),
      MenuItem.separator(),
      MenuItem(
        key: SystemTrayAction.exitApp.key,
        label: SystemTrayAction.exitApp.translation(_t),
      ),
    ];
    if (menuItems != null) {
      items.insertAll(0, menuItems);
    }
    loggy.debug('tray: menu items length: ${items.length}');
    await trayManager.setContextMenu(Menu(items: items));
  }

  Future<void> updateSystemTray({
    required String configPath,
    required List<ClashProxyGroup> selectors,
    required bool isSystemProxy,
  }) async {
    if (!PlatformUtils.isDesktop) return;
    loggy.debug('tray: updating system tray');
    final stringList = List<MenuItem>.empty(growable: true);
    stringList.add(
      // TODO: translate
      MenuItem(label: "profile: $configPath", disabled: true),
    );
    if (selectors.isNotEmpty) {
      for (final selector in selectors) {
        stringList.add(
          MenuItem(
            label: "${selector.name}: ${selector.now}",
            disabled: true,
          ),
        );
      }
    }
    // system proxy
    stringList.add(MenuItem.separator());
    // TODO: translate
    if (!isSystemProxy) {
      stringList.add(
        MenuItem(
          key: SystemTrayAction.setSystemProxy.key,
          label: SystemTrayAction.setSystemProxy.translation(_t),
          toolTip: "click to set fclash as system proxy",
        ),
      );
    } else {
      stringList.add(MenuItem(label: "System proxy now", disabled: true));
      stringList.add(
        MenuItem(
          key: SystemTrayAction.unsetSystemProxy.key,
          label: SystemTrayAction.unsetSystemProxy.translation(_t),
          toolTip: "click to reset system proxy",
        ),
      );
      stringList.add(MenuItem.separator());
    }
    await setupSystemTray(stringList);
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    loggy.debug('tray: menu item clicked, key=[${menuItem.key}]');
    if (menuItem.key == null) return;
    switch (SystemTrayAction.fromKey(menuItem.key!)) {
      case SystemTrayAction.setSystemProxy:
        setSystemProxy();
        break;
      case SystemTrayAction.unsetSystemProxy:
        clearSystemProxy();
        break;
      default:
        loggy.debug(menuItem.key);
    }
  }
}
