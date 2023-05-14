import 'package:clashify/domain/clash/clash.dart';
import 'package:clashify/domain/enums.dart';

abstract class ClashDataSource {
  Future<ClashProxyGroup?> getProxy(String name);

  Future<List<ClashProxyGroup>> getProxies();

  Future<int?> getProxyDelay(String name, String url);

  Future<bool> changeProxy({
    required String selectorName,
    required String proxyName,
  });

  Future<ClashConfig?> getConfigs();

  Future<bool> changeConfig(String path);

  Future<bool> patchConfigs(ClashConfig config);

  Future<String?> getClashVersion();

  Stream<ClashLog> watchLogs(LogLevel level);

  Future<bool> closeAllConnections();

  Future<bool> closeConnections(String id);

  Stream<ClashTraffic> watchTraffic();

  Stream<ClashConnection> watchConnections();
}
