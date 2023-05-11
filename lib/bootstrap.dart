import 'dart:io';

import 'package:fclash/core/app/app.dart';
import 'package:fclash/core/clash/clash.dart';
import 'package:fclash/core/prefs/theme/theme.dart';
import 'package:fclash/data/data_providers.dart';
import 'package:fclash/data/profiles_store.dart';
import 'package:fclash/features/proxies/notifier/proxies_notifier.dart';
import 'package:fclash/services/service_providers.dart';
import 'package:fclash/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loggy/loggy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

final _loggy = Loggy('bootstrap');

final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;

Future<void> lazyBootstrap(WidgetsBinding widgetsBinding) async {
  runApp(
    const Material(
      child: CircularProgressIndicator(),
    ),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [Data.sharedPreferences.overrideWithValue(sharedPreferences)],
  );

  await initBaseDependencies();
  await initPlatformDependencies();
  await initPreferences(container.read);
  await initAppServices(container.read);

  runApp(
    ProviderScope(
      parent: container,
      child: const AppView(),
    ),
  );
}

Future<void> initBaseDependencies() async {
  Loggy.initLoggy();
}

Future<void> initPreferences(
  Result Function<Result>(ProviderListenable<Result>) read,
) async {
  await read(ThemeController.provider.notifier).init();
  await read(ProfileStore.provider.notifier).init();
}

Future<void> initAppServices(
  Result Function<Result>(ProviderListenable<Result>) read,
) async {
  await read(Services.notification).init();
  await read(ClashController.provider.notifier).init();
  // await read(Services.clash).init(read(ClashPrefsController.provider));
  await read(ProxiesNotifier.provider.notifier).init();
  if (PlatformUtils.isDesktop) await read(Services.autoStart).init();
  _loggy.debug('initialized app services');
}

Future<void> initPlatformDependencies() async {
  if (isDesktop) {
    await Future.wait([
      Future.microtask(() async {
        await windowManager.ensureInitialized();
        await windowManager.setPreventClose(true);
      })
    ]);
    // WindowOptions opts = const WindowOptions(
    //   minimumSize: Size(1024, 768),
    //   size: Size(1024, 768),
    //   titleBarStyle: TitleBarStyle.hidden,
    // );
    // windowManager.waitUntilReadyToShow(opts, () {
    //   // hide window when start
    //   // if (Get.find<ClashService>().isHideWindowWhenStart() && kReleaseMode) {
    //   //   if (Platform.isMacOS) {
    //   //     windowManager.minimize();
    //   //   } else {
    //   //     windowManager.hide();
    //   //   }
    //   // }
    // });
  }
  _loggy.debug('initialized platform dependencies');
}
