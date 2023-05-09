import 'dart:io';

import 'package:clashify/main.dart';
import 'package:clashify/screen/component/speed.dart';
import 'package:clashify/screen/controller/theme_controller.dart';
import 'package:clashify/screen/page/about.dart';
import 'package:clashify/screen/page/clash_log.dart';
import 'package:clashify/screen/page/connection.dart';
import 'package:clashify/screen/page/profile.dart';
import 'package:clashify/screen/page/proxy.dart';
import 'package:clashify/screen/page/setting.dart';
import 'package:clashify/service/clash_service.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kommon/kommon.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with WindowListener, TrayListener {
  var index = 0.obs;
  final pages = const [
    Proxy(),
    Profile(),
    Setting(),
    Connections(),
    ClashLog(),
    AboutPage()
  ];

  @override
  void onWindowClose() {
    super.onWindowClose();
    if (Platform.isMacOS) {
      windowManager.minimize();
    } else {
      windowManager.hide();
    }
  }

  @override
  void onTrayIconMouseDown() {
    // windowManager.focus();
    windowManager.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    super.onTrayIconRightMouseDown();
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'exit':
        windowManager.close().then((value) async {
          await Get.find<ClashService>().closeClashDaemon();
          exit(0);
        });
        break;
      case 'show':
        windowManager.focus();
        windowManager.show();
    }
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    trayManager.addListener(this);
    changeTheme();
    // ignore
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isDesktop ? _buildDesktop() : _buildMobile();
  }

  _buildMobile() {
    return SafeArea(
      child: Scaffold(
          appBar: BrnAppBar(
            title: "Clashify",
            brightness: Brightness.dark,
            actions: InkWell(
              onTap: () {
                launchUrlString("https://github.com/hiddify/Fclash", mode: LaunchMode.externalApplication);
              },
              child: Icon(Icons.question_mark_sharp)),
          ),
          body: Column(
            children: [buildMobileOptions(), Expanded(child: buildFrame())],
          )),
    );
  }

  _buildDesktop() {
    final cs = Get.find<ClashService>();
    return DragToResizeArea(
      child: Scaffold(
          body: Column(
        children: [
          buildDesktopOptions(),
          Obx(() => BrnNoticeBar(
            backgroundColor: Get.find<ThemeController>().isDark == true ? Colors.black : null,
              content:
                  'Current using'.trParams({"name": cs.currentYaml.value}))),
          Obx(() => BrnNoticeBar(
            backgroundColor: Get.find<ThemeController>().isDark == true ? Colors.black : null,
                noticeStyle: cs.isSystemProxyObs.value
                    ? NoticeStyles.succeedWithArrow
                    : NoticeStyles.warningWithArrow,
                content: cs.isSystemProxyObs.value
                    ? "Clashify is running as system proxy now. Enjoy.".tr
                    : 'Clashify is not set as system proxy. Software may not automatically use Fclash proxy.'
                        .tr,
                rightWidget: cs.isSystemProxyObs.value
                    ? TextButton(
                        onPressed: () {
                          cs.clearSystemProxy();
                        },
                        child: Text("Cancel".tr))
                    : TextButton(
                        onPressed: () {
                          cs.setSystemProxy();
                        },
                        child: Text("set Clashify as system proxy".tr)),
              )),
          Expanded(
              child: Row(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildOptions(0, 'Proxy'.tr,
                              icon: SvgPicture.asset(
                                "assets/images/代理管理工具.svg",
                                width: 30.0,
                                fit: BoxFit.contain,
                                color: Colors.white,
                              )),
                          _buildOptions(1, 'Profile'.tr,
                              icon: SvgPicture.asset(
                                "assets/images/文件.svg",
                                width: 30.0,
                                fit: BoxFit.contain,
                                color: Colors.white,
                              )),
                          _buildOptions(2, 'Setting'.tr,
                              icon: SvgPicture.asset(
                                "assets/images/设置.svg",
                                width: 30.0,
                                fit: BoxFit.contain,
                                color: Colors.white,
                              )),
                          _buildOptions(3, 'Connections'.tr,
                              icon: SvgPicture.asset(
                                "assets/images/连接.svg",
                                width: 30.0,
                                fit: BoxFit.contain,
                                color: Colors.white,
                              )),
                          _buildOptions(4, 'Log'.tr,
                              icon: SvgPicture.asset(
                                "assets/images/日志.svg",
                                width: 30.0,
                                fit: BoxFit.contain,
                                color: Colors.white,
                              )),
                          _buildOptions(5, 'About'.tr,
                              icon: SvgPicture.asset(
                                "assets/images/关于.svg",
                                width: 30.0,
                                fit: BoxFit.contain,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(child: buildFrame()),
            ],
          ))
        ],
      )),
    );
  }

  Widget buildDesktopOptions() {
    final nonSelectedColor = Colors.grey.shade400;
    const selectedColor = Colors.blueAccent;
    const style = TextStyle(color: Colors.white);
    return Obx(
      () {
        final mode =
            Get.find<ClashService>().configEntity.value?.mode ?? "Direct";
        debugPrint("current mode: $mode");
        return GestureDetector(
          onPanStart: (_) {
            windowManager.startDragging();
          },
          child: SizedBox(
            height: 75,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const AppIcon().marginOnly(top: Platform.isMacOS ? 12.0 : 0.0),
                // Switch
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.find<ClashService>()
                              .changeConfigField('mode', 'Rule');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: mode == "rule"
                                  ? selectedColor
                                  : nonSelectedColor,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  bottomLeft: Radius.circular(12.0))),
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            "rule".tr,
                            style: style,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.find<ClashService>()
                              .changeConfigField('mode', 'Global');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: mode == "global"
                                  ? selectedColor
                                  : nonSelectedColor),
                          padding: const EdgeInsets.all(12.0),
                          child: Text("global".tr, style: style),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.find<ClashService>()
                              .changeConfigField('mode', 'Direct');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: mode == "direct"
                                  ? selectedColor
                                  : nonSelectedColor,
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12.0),
                                  bottomRight: Radius.circular(12.0))),
                          padding: const EdgeInsets.all(12.0),
                          child: Text("direct".tr, style: style),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                      alignment: Alignment.center,
                      decoration:
                          const BoxDecoration(color: Colors.transparent),
                      child: const SpeedWidget()),
                ),
                const WindowPanel()
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildMobileOptions() {
    final cs = Get.find<ClashService>();
    return Column(
      children: [
        Obx(() => BrnNoticeBar(
              content:
                  'Current using'.trParams({"name": cs.currentYaml.value}))),
          Obx(() => BrnNoticeBar(
                noticeStyle: cs.isSystemProxyObs.value
                    ? NoticeStyles.succeedWithArrow
                    : NoticeStyles.warningWithArrow,
                content: cs.isSystemProxyObs.value
                    ? "Clashify is running as system proxy now. Enjoy.".tr
                    : 'Clashify is not set as system proxy. Software may not automatically use Fclash proxy.'
                        .tr,
                rightWidget: cs.isSystemProxyObs.value
                    ? TextButton(
                        onPressed: () {
                          cs.clearSystemProxy();
                        },
                        child: Text("Cancel".tr))
                    : TextButton(
                        onPressed: () {
                          cs.setSystemProxy();
                        },
                        child: Text("set Clashify as system proxy".tr)),
              )),
        SizedBox(
          height: 75,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              children: [
                _buildOptions(0, 'Proxy'.tr),
                _buildOptions(1, 'Profile'.tr),
                _buildOptions(2, 'Setting'.tr),
                _buildOptions(3, 'Connections'.tr),
                _buildOptions(4, 'Log'.tr),
                _buildOptions(5, 'About'.tr),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(int index, String title, {Widget? icon}) {
    return Obx(
      () {
        final selected = index == this.index.value;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          width: 128.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: selected
                  ? Colors.blueAccent
                  : Color.fromARGB(255, 171, 170, 170)),
          child: InkWell(
            onTap: () {
              this.index.value = index;
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: icon,
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildFrame() {
    return Obx(
      () => pages[index.value],
    );
  }

  void changeTheme() {
    Future.delayed(Duration.zero, () {
      final isDark = SpUtil.getData<bool>('dark_theme', defValue: false);
      Get.find<ThemeController>()
          .changeTheme(isDark ? ThemeType.dark : ThemeType.light);
    });
  }
}

class WindowPanel extends StatelessWidget {
  const WindowPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Ink(
            child: InkWell(
                onTap: () {
                  windowManager.minimize();
                },
                child: const Icon(Icons.minimize).paddingAll(8.0))),
        Ink(
            child: InkWell(
                onTap: () async {
                  if (await windowManager.isMaximized()) {
                    windowManager.unmaximize();
                  } else {
                    windowManager.maximize();
                  }
                },
                child: const Icon(Icons.rectangle_outlined).paddingAll(8.0))),
        Ink(
            child: InkWell(
                onTap: () {
                  windowManager.close();
                },
                child: const Icon(Icons.close).paddingAll(8.0))),
      ],
    );
  }
}

class AppIcon extends StatelessWidget {
  const AppIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      child: const CircleAvatar(
        foregroundImage: AssetImage("assets/images/logo.png"),
        radius: 20,
      ),
    );
  }
}
