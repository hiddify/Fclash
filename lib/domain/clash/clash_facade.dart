import 'package:clashify/domain/clash/clash.dart';
import 'package:clashify/domain/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract class ClashFacade {
  Future<Either<Failure, Unit>> start();
  Stream<Either<Failure, List<ClashProxyGroup>>> watchSelectors();
  Future<Either<Failure, ClashProxyGroup?>> getProxy(String name);
  Stream<Either<Failure, ClashConfig>> watchConfigOverrides();
  // Future<Either<Failure, List<ClashProxyGroup>>> getProxies();
  // Future<Either<Failure, ClashConfig?>> getConfigOverrides();
  // Future<Either<Failure, Unit>> changeConfigOverrides(String path);
  Future<Either<Failure, Unit>> updateConfigOverrides(ClashConfigPatch patch);
  Future<Either<Failure, Unit>> changeProxy(
    String selectorName,
    String proxyName,
  );
  Future<Either<Failure, Unit>> setSystemProxy();
  Future<Either<Failure, Unit>> clearSystemProxy();
  Future<Either<Failure, Unit>> closeConnections(String id);
  Future<Either<Failure, Unit>> closeAllConnections();
  Stream<Either<Failure, ClashTraffic>> watchTraffic();
  Stream<Either<Failure, ClashLog>> watchLogs();
  Stream<Either<Failure, ClashConnection>> watchConnections();
}
