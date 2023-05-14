// import 'dart:async';

// import 'package:clashify/domain/models/clash_config.dart';
// import 'package:clashify/domain/models/clash_connection.dart';
// import 'package:clashify/domain/models/clash_log.dart';
// import 'package:clashify/domain/models/clash_proxy_group.dart';

// abstract class ClashService {
//   Future<void> init(String configFileName, ClashConfig overrides);

//   Future<ClashConfig> getCurrentConfig();

//   Future<List<ClashProxyGroup>> getProxyGroups();

//   Stream<ClashConnection> watchConnections({
//     Duration interval = const Duration(seconds: 1),
//   });

//   Future<bool> setConfigById(String id);

//   Future<bool> closeConnection(String connectionId);

//   Future<void> closeAllConnections();

//   Future<void> closeClashDaemon();

//   Future<bool> changeProxy(String selectName, String proxyName);

//   Future<bool> changeConfigFields(ClashConfig config);

//   Future<void> setSystemProxy({
//     required int httpPort,
//     required int socksPort,
//   });

//   Future<void> clearSystemProxy();

//   Future<bool> validateConfigByPath(String path);

//   Stream<Map<String, int>> testProxies(Iterable<String> proxyNames);

//   Stream<ClashLog> startLogging();

//   Future<void> stopLogging();
// }

import 'dart:async';

abstract class ClashService {
  Future<void> init();

  // Future<bool> start(String configFileName);

  Future<bool> start();

  Future<void> setSystemProxy({
    required int httpPort,
    required int socksPort,
  });

  Future<void> clearSystemProxy();
}
