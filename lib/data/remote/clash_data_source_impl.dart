import 'dart:convert';
import 'dart:io';

import 'package:clashify/data/remote/clash_data_source.dart';
import 'package:clashify/domain/clash/clash.dart';
import 'package:clashify/domain/constants.dart';
import 'package:clashify/domain/enums.dart';
import 'package:clashify/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// HACK: not complete

class ClashDataSourceImpl with InfraLogger implements ClashDataSource {
  final _clashDio = Dio(
    BaseOptions(
      baseUrl: "http://${Networks.localHost}:${Networks.port}",
      connectTimeout: const Duration(seconds: 3),
      sendTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  // HACK: not sure if we should handle simple proxies (non groups)
  @override
  Future<ClashProxyGroup?> getProxy(String name) async {
    loggy.debug('getting proxy with name: [$name]');
    final response =
        await _clashDio.get<Map<String, dynamic>>('/proxies/$name');
    loggy.debug('proxy response: $response');
    final proxyJson = response.data?..putIfAbsent('name', () => name);
    loggy.debug('proxy json modified: $proxyJson');
    if (proxyJson == null) return null;
    return ClashProxyGroup.fromJson(proxyJson);
  }

  @override
  Future<List<ClashProxyGroup>> getProxies() async {
    loggy.debug('getting proxies');
    final response = await _clashDio.get<Map<String, dynamic>>('/proxies');
    loggy.debug('proxies response: $response');
    final proxiesJson = response.data?['proxies'] as Map<String, dynamic>?;
    final parsedProxies = proxiesJson?.entries.map(
      (e) {
        final proxyMap = (e.value as Map<String, dynamic>)
          ..putIfAbsent('name', () => e.key);
        return ClashProxyGroup.fromJson(proxyMap);
      },
    ).toList();
    loggy.debug('parsed proxies: $parsedProxies');
    return parsedProxies ?? [];
  }

  @override
  Future<int?> getProxyDelay(String name, String url) async {
    loggy.debug('getting proxy delay for [$name] on url: [$url]');
    final response = await _clashDio.get<Map<String, dynamic>>(
      '/proxies/$name/delay',
    );
    return response.data?['delay'] as int?;
  }

  @override
  Future<bool> changeProxy({
    required String selectorName,
    required String proxyName,
  }) async {
    loggy.debug(
      'changing proxy, selector: [$selectorName] <=> proxy: [$proxyName]',
    );
    final response = await _clashDio.put<void>(
      "/proxies/$selectorName",
      data: {"name": proxyName},
    );
    return response.statusCode == HttpStatus.noContent;
  }

  @override
  Future<ClashConfig?> getConfigs() async {
    loggy.debug('getting configs');
    final response = await _clashDio.get<Map<String, dynamic>>('/configs');
    if (response.data == null) return null;
    return ClashConfig.fromJson(response.data!);
  }

  @override
  Future<bool> patchConfigs(ClashConfig config) async {
    final patchJson = config.toJson();
    loggy.debug('patching configs, overrides: [$patchJson]');
    final response = await _clashDio.patch<void>(
      "/configs",
      data: patchJson,
    );
    return response.statusCode == HttpStatus.noContent;
  }

  @override
  Future<bool> changeConfig(String path) async {
    loggy.debug('changing config, path: $path');
    final response = await _clashDio.put(
      "/configs",
      queryParameters: {"force": true},
      data: {"path": path},
    );
    return response.statusCode == HttpStatus.noContent;
  }

  @override
  Future<bool> closeAllConnections() async {
    loggy.debug('closing all connections');
    final response = await _clashDio.delete("/connections");
    return response.statusCode == HttpStatus.noContent;
  }

  @override
  Future<bool> closeConnections(String id) async {
    loggy.debug('closing connection, id: [$id]');
    final response = await _clashDio.delete("/connections/$id");
    return response.statusCode == HttpStatus.noContent;
  }

  @override
  Future<String?> getClashVersion() async {
    loggy.debug('getting clash version');
    final response = await _clashDio.get<Map<String, dynamic>>("/version");
    return response.data?["version"] as String?;
  }

  @override
  Stream<ClashLog> watchLogs(LogLevel level) {
    loggy.debug('watching logs, level= $level');
    final channel = WebSocketChannel.connect(
      Uri.parse(
        "ws://${Networks.localHost}:${Networks.port}/logs?level=${level.name}",
      ),
    );
    return channel.stream.map(
      (event) => ClashLog.fromJson(
        jsonDecode(event as String) as Map<String, dynamic>,
      ),
    );
  }

  @override
  Stream<ClashTraffic> watchTraffic() {
    loggy.debug('watching traffic');
    final channel = WebSocketChannel.connect(
      Uri.parse("ws://${Networks.localHost}:${Networks.port}/traffic"),
    );
    return channel.stream.map(
      (event) => ClashTraffic.fromJson(
        jsonDecode(event as String) as Map<String, dynamic>,
      ),
    );
  }

  @override
  Stream<ClashConnection> watchConnections() {
    loggy.debug('watching connections');
    final channel = WebSocketChannel.connect(
      Uri.parse("ws://${Networks.localHost}:${Networks.port}/connections"),
    );
    return channel.stream.map(
      (event) => ClashConnection.fromJson(
        jsonDecode(event as String) as Map<String, dynamic>,
      ),
    );
  }
}
