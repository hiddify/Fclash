import 'dart:io';

import 'package:clashify/utils/utils.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';

class AutoStartService {
  final status = BehaviorSubject<bool>();

  Future<void> init() async {
    // setup
    final packageInfo = await PackageInfo.fromPlatform();
    if (PlatformUtils.isDesktop) {
      launchAtStartup.setup(
        appName: packageInfo.appName,
        appPath: Platform.resolvedExecutable,
      );
      status.value = await launchAtStartup.isEnabled();
    }
  }

  Future<bool> enableAutostart() async {
    if (!PlatformUtils.isDesktop) {
      return false;
    }
    return status.value = await launchAtStartup.enable();
  }

  Future<bool> disableAutostart() async {
    if (!PlatformUtils.isDesktop) {
      return false;
    }
    return status.value = !(await launchAtStartup.disable());
  }
}
