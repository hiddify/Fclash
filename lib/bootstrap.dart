import 'dart:io';

import 'package:clashify/core/app/app.dart';
import 'package:clashify/core/prefs/theme/theme.dart';
import 'package:clashify/data/data_providers.dart';
import 'package:clashify/features/proxies/notifier/proxies_notifier.dart';
import 'package:clashify/services/service_providers.dart';
import 'package:clashify/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loggy/loggy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

final _loggy = Loggy('bootstrap');

final isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;

Future<void> lazyBootstrap(WidgetsBinding widgetsBinding) async {
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // temporary solution: https://github.com/rrousselGit/riverpod/issues/1874
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [Data.sharedPreferences.overrideWithValue(sharedPreferences)],
  );

  await initBaseDependencies();
  await initPreferences(container.read);
  await initAppServices(container.read);

  runApp(
    ProviderScope(
      parent: container,
      child: const AppView(),
    ),
  );

  FlutterNativeSplash.remove();
}

Future<void> initBaseDependencies() async {
  Loggy.initLoggy();
}

Future<void> initPreferences(
  Result Function<Result>(ProviderListenable<Result>) read,
) async {
  await read(ThemeController.provider.notifier).init();
}

Future<void> initAppServices(
  Result Function<Result>(ProviderListenable<Result>) read,
) async {
  await read(Services.filesEditor).init();
  await read(Services.notification).init();
  await read(Facade.clash).start();
  await read(ProxiesNotifier.provider.notifier).init();
  if (PlatformUtils.isDesktop) await read(Services.autoStart).init();
  _loggy.debug('initialized app services');
}
