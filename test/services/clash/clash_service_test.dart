// import 'package:fclash/data/preferences/preferences.dart';
// import 'package:fclash/services/clash/clash.dart';
// import 'package:fclash/services/notification/notification.dart';
// import 'package:fclash/utils/preferences.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:loggy/loggy.dart';
// import 'package:proxy_manager/proxy_manager.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   late NotificationService notificationService;
//   late ProxyManager proxyManager;
//   late ClashService clashService;

//   setUpAll(
//     () {
//       Loggy.initLoggy();

//       TestWidgetsFlutterBinding.ensureInitialized();
//       // expose path_provider -> https://github.com/flutter/flutter/issues/10912
//       const MethodChannel channel =
//           MethodChannel('plugins.flutter.io/path_provider');
//       channel.setMockMethodCallHandler((MethodCall methodCall) async {
//         return ".";
//       });
//     },
//   );

//   setUp(
//     () async {
//       TestWidgetsFlutterBinding.ensureInitialized();
//       SharedPreferences.setMockInitialValues({});
//       final sharedPreferences = await SharedPreferences.getInstance();
//       final preferences =
//           Preferences.basic(sharedPreferences: sharedPreferences);
//       notificationService = NotificationService();
//       await notificationService.init();
//       proxyManager = ProxyManager();
//       clashService = ClashServiceImpl(
//         notification: notificationService,
//         proxyManager: proxyManager,
//         prefs: ClashPreferences(preferences),
//       );
//     },
//   );

//   tearDown(
//     () async {
//       clashService.closeAllConnections();
//       await clashService.closeClashDaemon();
//     },
//   );

//   group(
//     'init',
//     () {
//       test(
//         'description',
//         () async {
//           await clashService.init();
//         },
//       );
//     },
//   );

//   group(
//     'getConnections',
//     () {
//       setUp(
//         () async {
//           await clashService.init();
//         },
//       );

//       test(
//         'description',
//         () async {
//           // final connections = clashService.getConnections();
//           // await clashService.setSystemProxy();
//         },
//       );
//     },
//   );
// }
