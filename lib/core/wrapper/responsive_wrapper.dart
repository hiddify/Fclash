// import 'package:fclash/core/core_providers.dart';
// import 'package:fclash/core/router/router.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:recase/recase.dart';

// class ResponsiveWrapperPage extends HookConsumerWidget {
//   const ResponsiveWrapperPage(this.child, {super.key});

//   final Widget child;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final t = ref.watch(Core.translations);
//     final router = ref.watch(AppRouter.provider);

//     return AdaptiveScaffold(
//       destinations: [
//         NavigationDestination(
//           icon: const Icon(Icons.router),
//           label: t.proxy.pageTitle.titleCase,
//         ),
//         const NavigationDestination(
//           icon: Icon(Icons.portable_wifi_off),
//           label: 'profiles',
//         ),
//         NavigationDestination(
//           icon: const Icon(Icons.wifi),
//           label: t.connections.pageTitle.titleCase,
//         ),
//         NavigationDestination(
//           icon: const Icon(Icons.assignment),
//           label: t.logs.pageTitle.titleCase,
//         ),
//         NavigationDestination(
//           icon: const Icon(Icons.settings),
//           label: t.settings.pageTitle.titleCase,
//         ),
//       ],
//       selectedIndex: router.currentTabIndex,
//       onSelectedIndexChange: router.changeTab,
//       useDrawer: false,
//       internalAnimations: false,
//       body: (context) => child,
//     );
//   }
// }

import 'dart:io';

import 'package:fclash/core/core_providers.dart';
import 'package:fclash/core/router/router.dart';
import 'package:fclash/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class ResponsiveWrapper extends StatefulHookConsumerWidget {
  const ResponsiveWrapper(this.child, {super.key});

  final Widget child;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ResponsiveWrapperState();
}

class _ResponsiveWrapperState extends ConsumerState<ResponsiveWrapper>
    with WindowListener, TrayListener, PresLogger {
  @override
  Widget build(BuildContext context) {
    final t = ref.watch(Core.translations);
    final router = ref.watch(AppRouter.provider);

    return AdaptiveScaffold(
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.router),
          label: t.proxies.pageTitle.titleCase,
        ),
        NavigationDestination(
          icon: const Icon(Icons.portable_wifi_off),
          label: t.profiles.pageTitle.titleCase,
        ),
        NavigationDestination(
          icon: const Icon(Icons.wifi),
          label: t.connections.pageTitle.titleCase,
        ),
        NavigationDestination(
          icon: const Icon(Icons.assignment),
          label: t.logs.pageTitle.titleCase,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings),
          label: t.settings.pageTitle.titleCase,
        ),
      ],
      selectedIndex: router.currentTabIndex,
      onSelectedIndexChange: router.changeTab,
      useDrawer: false,
      internalAnimations: false,
      body: (context) => widget.child,
    );
  }

  @override
  void initState() {
    super.initState();
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    loggy.debug('added window and tray listeners');
  }

  @override
  void onWindowClose() {
    super.onWindowClose();
    if (Platform.isMacOS) {
      windowManager.minimize();
    } else {
      windowManager.hide();
    }
    loggy.debug('window: on window close triggered');
  }

  @override
  void onTrayIconMouseDown() {
    // windowManager.focus();
    windowManager.show();
    loggy.debug('tray: icon clicked');
  }

  @override
  void onTrayIconRightMouseDown() {
    super.onTrayIconRightMouseDown();
    trayManager.popUpContextMenu();
    loggy.debug('tray: icon right clicked');
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    loggy.debug('tray: menu item clicked, key=[${menuItem.key}]');
    switch (menuItem.key) {
      case 'exit':
        windowManager.close().then((value) async {
          // ref.read(Services.clash).closeClashDaemon();
          exit(0);
        });
        break;
      case 'show':
        windowManager.focus();
        windowManager.show();
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    loggy.debug('removing window and tray listeners');
    super.dispose();
  }
}
