// import 'dart:async';
// import 'dart:convert';
// import 'dart:ffi' as ffi;
// import 'dart:io';
// import 'dart:isolate';

// import 'package:clashify/domain/models/clash_config.dart';
// import 'package:clashify/domain/models/clash_connection.dart';
// import 'package:clashify/domain/models/clash_log.dart';
// import 'package:clashify/domain/models/clash_proxy_group.dart';
// import 'package:clashify/gen/generated_bindings.dart';
// import 'package:clashify/services/clash/clash_service.dart';
// import 'package:clashify/utils/utils.dart';
// import 'package:ffi/ffi.dart';
// import 'package:flutter/services.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'package:proxy_manager/proxy_manager.dart';

// class ClashServiceImpl with InfraLogger implements ClashService {
//   ClashServiceImpl({
//     required this.proxyManager,
//   }) {
//     // load lib
//     var fullPath = "";
//     // https://github.com/dart-lang/ffi/issues/39
//     if (Platform.environment.containsKey('FLUTTER_TEST')) {
//       fullPath = "clash";
//     }
//     if (Platform.isWindows) {
//       fullPath = p.join(fullPath, "libclash.dll");
//     } else if (Platform.isMacOS) {
//       fullPath = p.join(fullPath, "libclash.dylib");
//     } else {
//       fullPath = p.join(fullPath, "libclash.so");
//     }
//     loggy.debug('ffi path: "$fullPath"');
//     final lib = ffi.DynamicLibrary.open(fullPath);
//     clashFFI = ClashNativeLibrary(lib);
//     clashFFI.init_native_api_bridge(ffi.NativeApi.initializeApiDLData);
//   }

//   static const mobileChannel = MethodChannel("FClashPlugin");
//   static const clashBaseUrl = "http://127.0.0.1:$clashExtPort";
//   static const clashExtPort = 22345;

//   late ClashNativeLibrary clashFFI;
//   late Directory _clashDirectory;
//   RandomAccessFile? _clashLock;

//   final ProxyManager proxyManager;

//   @override
//   Future<void> init(String configFileName, ClashConfig overrides) async {
//     loggy.debug('initializing');
//     final supportDir = await getApplicationSupportDirectory();

//     // init clash, kill all other clash clients
//     _clashDirectory = Directory(p.join(supportDir.path, "clash"));
//     loggy.debug("clash work directory: ${_clashDirectory.path}");

//     final configPath = p.join(_clashDirectory.path, configFileName);
//     final countryMMdb = p.join(_clashDirectory.path, 'Country.mmdb');
//     if (!await _clashDirectory.exists()) {
//       loggy.debug("clash directory doesn't exist, creating");
//       await _clashDirectory.create(recursive: true);
//     }
//     // copy executable to directory
//     final mmdb = await rootBundle.load('assets/tp/clash/Country.mmdb');
//     // write to clash dir
//     final mmdbF = File(countryMMdb);
//     if (!mmdbF.existsSync()) {
//       await mmdbF.writeAsBytes(mmdb.buffer.asInt8List());
//     }
//     final defaultConfigFile =
//         await rootBundle.load('assets/tp/clash/config.yaml');
//     // write to clash dir
//     final configFile = File(configPath);
//     if (!configFile.existsSync()) {
//       await configFile.writeAsBytes(defaultConfigFile.buffer.asInt8List());
//     }
//     // create or detect lock file
//     await _acquireLock(_clashDirectory);
//     // ffi
//     clashFFI.set_home_dir(_clashDirectory.path.toNativeUtf8().cast());
//     clashFFI.clash_init(_clashDirectory.path.toNativeUtf8().cast());
//     clashFFI.set_config(configPath.toNativeUtf8().cast());
//     clashFFI.set_ext_controller(clashExtPort);
//     if (clashFFI.parse_options() == 0) {
//       loggy.info('config parse OK');
//     }
//     // apply overrides
//     await changeConfigFields(overrides);
//   }

//   void getConfigs() {
//     // final profiles = <Profile>[];
//     // final entities = _clashDirectory.listSync();
//     // for (final entity in entities) {
//     //   if (entity.path.toLowerCase().endsWith('.yaml')) {
//     //     profiles.add(Profile(name: entity.path));
//     //     loggy.debug('detected: ${entity.path}');
//     //   }
//     // }
//     // _profiles.add(profiles);
//   }

//   Future<ClashConnection> getConnections() async {
//     loggy.debug('getting connection');
//     final String connections =
//         clashFFI.get_all_connections().cast<Utf8>().toDartString();
//     final connectionsJson = json.decode(connections);
//     loggy.debug('connections json: $connectionsJson');
//     final connection =
//         ClashConnection.fromJson(connectionsJson as Map<String, dynamic>);
//     loggy.debug('parsed connection: $connection');
//     return connection;
//   }

//   @override
//   Stream<ClashConnection> watchConnections({Duration? interval}) async* {
//     loggy.debug('watching connections');
//     yield* Stream.periodic(
//       interval ?? const Duration(seconds: 1),
//       (_) => getConnections(),
//     ).asyncMap((event) async => event);
//   }

//   @override
//   Future<void> closeAllConnections() async {
//     loggy.debug('closing all connections');
//     clashFFI.close_all_connections();
//   }

//   @override
//   Future<bool> closeConnection(String connectionId) async {
//     final id = connectionId.toNativeUtf8().cast<ffi.Char>();
//     return clashFFI.close_connection(id) == 1;
//   }

//   @override
//   Future<ClashConfig> getCurrentConfig() async {
//     final config = ClashConfig.fromJson(
//       json.decode(clashFFI.get_configs().cast<Utf8>().toDartString())
//           as Map<String, dynamic>,
//     );
//     loggy.debug('current config= $config');
//     return config;
//   }

//   @override
//   Future<void> closeClashDaemon({bool isSystemProxy = false}) async {
//     loggy.info('closing clash daemon');
//     if (isSystemProxy) {
//       await clearSystemProxy();
//     }
//     await _clashLock?.unlock();
//   }

//   @override
//   Future<List<ClashProxyGroup>> getProxyGroups() async {
//     final proxiesJson = json.decode(
//       clashFFI.get_proxies().cast<Utf8>().toDartString(),
//     )['proxies'] as Map<String, dynamic>;
//     // loggy.debug('proxies json: $proxiesJson');

//     final parsedProxies = proxiesJson.entries
//         .map((e) => ClashProxyGroup.fromJson(e.value as Map<String, dynamic>))
//         .toList();

//     // loggy.debug('parsed proxies: $parsedProxies');
//     return parsedProxies;
//   }

//   @override
//   Future<bool> changeProxy(String selectName, String proxyName) async {
//     final ret = clashFFI.change_proxy(
//       selectName.toNativeUtf8().cast(),
//       proxyName.toNativeUtf8().cast(),
//     );
//     return ret == 0;
//   }

//   @override
//   Future<void> setSystemProxy({
//     required int httpPort,
//     required int socksPort,
//   }) async {
//     if (PlatformUtils.isDesktop) {
//       if (httpPort != 0) {
//         await Future.wait([
//           proxyManager.setAsSystemProxy(
//             ProxyTypes.http,
//             '127.0.0.1',
//             httpPort,
//           ),
//           proxyManager.setAsSystemProxy(
//             ProxyTypes.https,
//             '127.0.0.1',
//             httpPort,
//           )
//         ]);
//         loggy.debug("set http");
//       }
//       if (socksPort != 0 && !Platform.isWindows) {
//         loggy.debug("set socks");
//         await proxyManager.setAsSystemProxy(
//           ProxyTypes.socks,
//           '127.0.0.1',
//           socksPort,
//         );
//       }
//     } else {
//       if (httpPort != 0) {
//         await mobileChannel.invokeMethod(
//           "SetHttpPort",
//           {"port": httpPort},
//         );
//       }
//       mobileChannel.invokeMethod("StartProxy");
//     }
//   }

//   @override
//   Future<void> clearSystemProxy() async {
//     if (PlatformUtils.isDesktop) {
//       await proxyManager.cleanSystemProxy();
//     } else {
//       mobileChannel.invokeMethod("StopProxy");
//     }
//   }

//   // @override
//   // Future<bool> addProfile(String name, String url) async {
//   //   final configName = '$name.yaml';
//   //   final newProfilePath = join(_clashDirectory.path, configName);
//   //   try {
//   //     final uri = Uri.tryParse(url);
//   //     if (uri == null) {
//   //       return false;
//   //     }
//   //     final resp = await Dio(BaseOptions(
//   //             headers: {'User-Agent': 'Fclash'},
//   //             sendTimeout: 15000,
//   //             receiveTimeout: 15000))
//   //         .downloadUri(uri, newProfilePath, onReceiveProgress: (i, t) {
//   //       Get.printInfo(info: "$i/$t");
//   //     });
//   //     return resp.statusCode == 200;
//   //   } catch (e) {
//   //     BrnToast.show("Error: ${e}", Get.context!);
//   //   } finally {
//   //     final f = File(newProfilePath);
//   //     if (f.existsSync() && await changeYaml(f)) {
//   //       // set subscription
//   //       await SpUtil.setData('profile_$name', url);
//   //       return true;
//   //     }
//   //     return false;
//   //   }
//   // }

//   // @override
//   // Future<bool> deleteProfile(FileSystemEntity config) async {
//   //   if (config.existsSync()) {
//   //     config.deleteSync();
//   //     await SpUtil.remove('profile_${basename(config.path)}');
//   //     reload();
//   //     return true;
//   //   } else {
//   //     return false;
//   //   }
//   // }

//   // void checkPort() {
//   //   final configOrNull = _config.valueOrNull;
//   //   if (configOrNull != null) {
//   //     if (configOrNull.httpPort == 0) {
//   //       changeConfigField('port', initializedHttpPort);
//   //     }
//   //     if (configOrNull.mixedPort == 0) {
//   //       changeConfigField('mixed-port', initializedMixedPort);
//   //     }
//   //     if (configOrNull.socksPort == 0) {
//   //       changeConfigField('socks-port', initializedSockPort);
//   //     }
//   //     // updateTray();
//   //   }
//   // }

//   /// yaml: test
//   // @override
//   // String getSubscriptionLinkByYaml(String yaml) {
//   //   final url = SpUtil.getData('profile_$yaml', defValue: "");
//   //   Get.printInfo(info: 'subs link for $yaml: $url');
//   //   return url;
//   // }

//   // @override
//   // Future<bool> updateSubscription(String name) async {
//   //   final configName = '$name.yaml';
//   //   final newProfilePath = join(_clashDirectory.path, configName);
//   //   final url = SpUtil.getData('profile_$name');
//   //   try {
//   //     final uri = Uri.tryParse(url);
//   //     if (uri == null) {
//   //       return false;
//   //     }
//   //     // delete exists
//   //     final f = File(newProfilePath);
//   //     final tmpF = File('$newProfilePath.tmp');

//   //     final resp = await Dio(BaseOptions(
//   //             headers: {'User-Agent': 'Fclash'},
//   //             sendTimeout: 15000,
//   //             receiveTimeout: 15000))
//   //         .downloadUri(uri, tmpF.path, onReceiveProgress: (i, t) {
//   //       Get.printInfo(info: "$i/$t");
//   //     }).catchError((e) {
//   //       if (tmpF.existsSync()) {
//   //         tmpF.deleteSync();
//   //       }
//   //     });
//   //     if (resp.statusCode == 200) {
//   //       if (f.existsSync()) {
//   //         f.deleteSync();
//   //       }
//   //       tmpF.renameSync(f.path);
//   //     }
//   //     // set subscription
//   //     await SpUtil.setData('profile_$name', url);
//   //     return resp.statusCode == 200;
//   //   } finally {
//   //     final f = File(newProfilePath);
//   //     if (f.existsSync()) {
//   //       await changeYaml(f);
//   //     }
//   //   }
//   // }

//   Future<void> _acquireLock(Directory clashDirectory) async {
//     final path = p.join(clashDirectory.path, "fclash.lock");
//     final lockFile = File(path);
//     if (!lockFile.existsSync()) {
//       lockFile.createSync(recursive: true);
//     }
//     try {
//       _clashLock = await lockFile.open(mode: FileMode.write);
//       await _clashLock?.lock();
//     } catch (e) {
//       exit(0);
//     }
//   }

//   @override
//   Future<bool> changeConfigFields(ClashConfig config) async {
//     try {
//       final map = config.toJson();
//       loggy.debug(map);
//       final int result = clashFFI.change_config_field(
//         json.encode(map).toNativeUtf8().cast(),
//       );
//       loggy.debug('change config fields result= $result');
//       return result == 0;
//     } finally {
//       // getCurrentClashConfig();
//       // if (field.endsWith("port") && isSystemProxy()) {
//       //   setSystemProxy();
//       // }
//     }
//   }

//   @override
//   Future<bool> setConfigById(String id) async {
//     final path = p.join(_clashDirectory.path, "$id.yaml");
//     loggy.debug('setting config with path= $path');
//     if (!await FileSystemEntity.isFile(path)) {
//       loggy.debug("path doesn't lead to a file");
//       return false;
//     }
//     try {
//       // check if it has `rule-set`, and try to convert it
//       // final content = await convertConfig(await File(path).readAsString());
//       final content = await File(path).readAsString();
//       if (content.isNotEmpty) {
//         await File(path).writeAsString(content);
//       }
//       if (clashFFI.is_config_valid(path.toNativeUtf8().cast()) == 0) {
//         // final resp = await Request.dioClient.put(
//         //   '/configs',
//         //   queryParameters: {"force": false},
//         //   data: {"path": path},
//         // );
//         // loggy.debug('config changed, ret: ${resp.statusCode}');
//         // // _configPath.value = basename(path); // replace
//         // // SpUtil.setData('yaml', _configPath.value); // replace
//         // return resp.statusCode == 204;
//         return true;
//       } else {
//         loggy.warning('config was not valid: $content');
//         // throw or return failure
//         await File(path).delete();
//         return false;
//       }
//     } catch (e) {
//       loggy.warning('failed to set config: $e');
//       return false;
//     }

//     // } finally {
//     //   reload();
//     // }
//   }

//   @override
//   Future<bool> validateConfigByPath(String path) async {
//     if (!await FileSystemEntity.isFile(path)) {
//       loggy.debug("path doesn't lead to a file");
//       return false;
//     }
//     return clashFFI.is_config_valid(path.toNativeUtf8().cast()) == 0;
//   }

//   // TODO: test
//   @override
//   Stream<Map<String, int>> testProxies(Iterable<String> proxyNames) async* {
//     for (final name in proxyNames) {
//       yield {name: await _delay(name)};
//     }
//   }

//   // test
//   Future<int> _delay(
//     String proxyName, {
//     int timeout = 5000,
//     String url = "https://www.google.com",
//   }) async {
//     try {
//       final completer = Completer<int>();
//       final receiver = ReceivePort();
//       clashFFI.async_test_delay(
//         proxyName.toNativeUtf8().cast(),
//         url.toNativeUtf8().cast(),
//         timeout,
//         receiver.sendPort.nativePort,
//       );
//       final subs = receiver.listen((message) {
//         if (!completer.isCompleted) {
//           final json = jsonDecode(message as String) as Map<String, dynamic>;
//           completer.complete(json['delay'] as int);
//         }
//       });
//       // 5s timeout, we add 1s
//       Future.delayed(const Duration(seconds: 6), () {
//         if (!completer.isCompleted) {
//           completer.complete(-1);
//         }
//         subs.cancel();
//       });
//       return completer.future;
//     } catch (e) {
//       return -1;
//     }
//   }

//   // TODO: test
//   @override
//   Stream<ClashLog> startLogging() {
//     loggy.debug('start logging');
//     final receiver = ReceivePort();
//     final logsStream = receiver.asBroadcastStream();
//     loggy.debug('log after adding stream');
//     final nativePort = receiver.sendPort.nativePort;
//     loggy.debug("logging native port: $nativePort");
//     clashFFI.start_log(nativePort);
//     return logsStream.map(
//       (event) => ClashLog.fromJson(
//         jsonDecode(event as String) as Map<String, dynamic>,
//       ),
//     );
//   }

//   @override
//   Future<void> stopLogging() async {
//     clashFFI.stop_log();
//   }
// }

import 'dart:ffi';
import 'dart:io';

import 'package:clashify/domain/constants.dart';
import 'package:clashify/gen/generated_bindings.dart';
import 'package:clashify/services/clash/clash_service.dart';
import 'package:clashify/utils/utils.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:proxy_manager/proxy_manager.dart';

class ClashServiceImpl with InfraLogger implements ClashService {
  final ProxyManager _proxyManager = ProxyManager();
  static const _mobileChannel = MethodChannel("FClashPlugin");
  late final Directory _clashDir;
  late final ClashNativeLibrary _clash;

  @override
  Future<void> init() async {
    loggy.debug('initializing');
    final directory = await getApplicationSupportDirectory();
    _clashDir = Directory(p.join(directory.path, Paths.clash));
    await _initClashLib();
    await _initConfig();
  }

  Future<void> _initClashLib() async {
    String fullPath = "";
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      fullPath = "clash";
    }
    if (Platform.isWindows) {
      fullPath = p.join(fullPath, "libclash.dll");
    } else if (Platform.isMacOS) {
      fullPath = p.join(fullPath, "libclash.dylib");
    } else {
      fullPath = p.join(fullPath, "libclash.so");
    }
    loggy.debug('ffi path: "$fullPath"');
    final lib = DynamicLibrary.open(fullPath);
    _clash = ClashNativeLibrary(lib);
  }

  Future<void> _initConfig() async {
    final configPath = p.join(_clashDir.path, Paths.config);
    final countryMMdb = p.join(_clashDir.path, Paths.countryMMDB);
    if (!await _clashDir.exists()) {
      loggy.debug("clash directory doesn't exist, creating");
      await _clashDir.create(recursive: true);
    }
    // copy executable to directory
    final mmdb = await rootBundle.load('assets/tp/clash/Country.mmdb');
    // write to clash dir
    final mmdbF = File(countryMMdb);
    if (!mmdbF.existsSync()) {
      await mmdbF.writeAsBytes(mmdb.buffer.asInt8List());
    }
    final defaultConfigFile =
        await rootBundle.load('assets/tp/clash/config.yaml');
    // write to clash dir
    final configFile = File(configPath);
    if (!configFile.existsSync()) {
      await configFile.writeAsBytes(defaultConfigFile.buffer.asInt8List());
    }
    // create or detect lock file
    // await _acquireLock(_clashDirectory);
  }

  // @override
  // Future<bool> start(String configFileName) async {
  //   loggy.debug('starting clash, config path: $configFileName');
  //   final path = p.join(_clashDir.path, '$configFileName.yaml');
  //   _clash.setHomeDir(_clashDir.path.toNativeUtf8().cast());
  //   _clash.setConfig(File(path).absolute.path.toNativeUtf8().cast());
  //   _clash.withExternalController(
  //     "${Networks.localHost}:${Networks.port}".toNativeUtf8().cast(),
  //   );
  //   return _clash.startService() == 1;
  // }

  @override
  Future<bool> start() async {
    loggy.debug('starting clash');
    _clash.setHomeDir(_clashDir.path.toNativeUtf8().cast());
    _clash.withExternalController(
      "${Networks.localHost}:${Networks.port}".toNativeUtf8().cast(),
    );
    return _clash.startService() == 1;
  }

  @override
  Future<void> setSystemProxy({
    required int httpPort,
    required int socksPort,
  }) async {
    if (PlatformUtils.isDesktop) {
      if (httpPort != 0) {
        await Future.wait([
          _proxyManager.setAsSystemProxy(
            ProxyTypes.http,
            Networks.localHost,
            httpPort,
          ),
          _proxyManager.setAsSystemProxy(
            ProxyTypes.https,
            Networks.localHost,
            httpPort,
          )
        ]);
        loggy.debug("set http");
      }
      if (socksPort != 0 && !Platform.isWindows) {
        loggy.debug("set socks");
        await _proxyManager.setAsSystemProxy(
          ProxyTypes.socks,
          Networks.localHost,
          socksPort,
        );
      }
    } else {
      if (httpPort != 0) {
        await _mobileChannel.invokeMethod(
          "SetHttpPort",
          {"port": httpPort},
        );
      }
      _mobileChannel.invokeMethod("StartProxy");
    }
  }

  @override
  Future<void> clearSystemProxy() async {
    if (PlatformUtils.isDesktop) {
      await _proxyManager.cleanSystemProxy();
    } else {
      _mobileChannel.invokeMethod("StopProxy");
    }
  }
}
