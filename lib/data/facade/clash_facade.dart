import 'dart:async';

import 'package:clashify/data/exception_handler.dart';
import 'package:clashify/data/remote/remote.dart';
import 'package:clashify/domain/clash/clash.dart';
import 'package:clashify/domain/enums.dart';
import 'package:clashify/domain/failures.dart';
import 'package:clashify/domain/profiles/profiles.dart';
import 'package:clashify/services/clash/clash.dart';
import 'package:clashify/services/files_editor_service.dart';
import 'package:clashify/utils/utils.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

// HACK: early implementation

class ClashFacadeImpl
    with ExceptionHandler, InfraLogger
    implements ClashFacade {
  ClashFacadeImpl({
    required this.clashRemote,
    required this.clashService,
    required this.profilesRepo,
    required this.preferences,
    required this.filesEditor,
  });

  final ClashDataSource clashRemote;
  final ClashService clashService;
  final ProfilesRepository profilesRepo;
  final Preferences preferences;
  final FilesEditorService filesEditor;

  late final _configOverridesStore = PrefStore(
    prefs: preferences,
    key: 'config_overrides',
    defaultValue: const ClashConfig(
      httpPort: 12346,
      socksPort: 12347,
      mixedPort: 12348,
    ),
    mapFrom: ClashConfig.fromJson,
    mapTo: (item) => item.toJson(),
    onUpdate: (value) {
      _configOverridesSubject.value = value;
      refresh();
    },
  );

  final _isSystemProxySubject = BehaviorSubject.seeded(false);
  final _configOverridesSubject = BehaviorSubject.seeded(const ClashConfig());
  final _selectorsSubject =
      BehaviorSubject<Either<Failure, List<ClashProxyGroup>>>.seeded(right([]));

  // @override
  // Future<void> start() async {
  //   loggy.debug('starting clash facade');
  //   await clashService.init();
  //   await clashService.start('config');
  //   final persistedOverrides = await _configOverridesStore.get();
  //   loggy.debug('persisted overrides: $persistedOverrides');
  //   await clashRemote.patchConfigs(persistedOverrides);
  //   final activeProfileStream = profilesRepo.watchActiveProfile();
  //   // TODO: use listeners
  //   activeProfileStream.skip(1).distinct(
  //     (previous, next) {
  //       return previous.match(
  //         (l) => false,
  //         (a) => next.match(
  //           (l) => false,
  //           (b) => a?.id == b?.id,
  //         ),
  //       );
  //     },
  //   ).listen(
  //     (event) async {
  //       await event.fold(
  //         (l) {},
  //         (r) async {
  //           if (r == null) return;
  //           await changeConfigOverrides(filesEditor.getConfigPath(r.id));
  //         },
  //       );
  //       await refresh();
  //     },
  //   );
  //   await activeProfileStream.first;
  // }

  @override
  Future<Either<Failure, Unit>> start() async {
    loggy.debug('starting clash facade');
    await clashService.init();
    await clashService.start();
    final persistedOverrides = await _configOverridesStore.get();
    loggy.debug('persisted overrides: $persistedOverrides');
    _configOverridesSubject.value = persistedOverrides;
    final activeProfileStream = profilesRepo.watchActiveProfile();
    // TODO: use listeners
    activeProfileStream.distinct(
      (previous, next) {
        loggy.debug(
          'new active profile received, old= $previous --- new= $next',
        );
        final isDistinct = previous.match(
          (l) => false,
          (a) => next.match(
            (l) => false,
            (b) => a?.id == b?.id,
          ),
        );
        loggy.debug('comparison result= $isDistinct');
        return isDistinct;
      },
    ).listen(
      (event) async {
        loggy.debug('distinct active profile: $event');
        // TODO: improve
        await event.fold(
          (l) {},
          (r) async {
            if (r == null) return;
            loggy.debug('active profile changed, changing config');
            await changeConfigOverrides(filesEditor.getConfigPath(r.id));
            await clashRemote.patchConfigs(_configOverridesSubject.value);
          },
        );
        await refresh();
      },
    );
    await activeProfileStream.first;
    return right(unit);
  }

  Future<void> refresh() async {
    loggy.debug('refreshing data');
    _selectorsSubject.value = await _getSelectors();
    await getConfigOverrides().then(
      (value) => value.map(
        (configOrNull) {
          if (configOrNull != null) {
            loggy.debug('in refresh: remote config= $configOrNull');
            _configOverridesSubject.value = configOrNull;
          }
        },
      ),
    );
  }

  @override
  Stream<Either<Failure, List<ClashProxyGroup>>> watchSelectors() {
    return _selectorsSubject.stream;
  }

  Future<Either<Failure, List<ClashProxyGroup>>> _getSelectors() async {
    return getProxies().then(
      (value) => value.map(
        (proxies) =>
            proxies.where((e) => e.type == ProxyType.selector).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, ClashProxyGroup?>> getProxy(String name) async {
    return exceptionHandler(
      () async {
        return right(await clashRemote.getProxy(name));
      },
    );
  }

  @override
  Future<Either<Failure, List<ClashProxyGroup>>> getProxies() {
    return exceptionHandler(
      () async {
        return right(await clashRemote.getProxies());
      },
    );
  }

  @override
  Future<Either<Failure, ClashConfig?>> getConfigOverrides() {
    return exceptionHandler(
      () async {
        return right(await clashRemote.getConfigs());
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> changeConfigOverrides(String path) {
    return exceptionHandler(
      () async {
        await clashRemote.changeConfig(path);
        return right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> updateConfigOverrides(ClashConfigPatch patch) {
    return exceptionHandler(
      () async {
        final newConfig = _configOverridesSubject.value.patch(patch);
        await clashRemote.patchConfigs(newConfig);
        if (_isSystemProxySubject.value &&
            (patch.httpPort?.isSome() ?? false)) {
          loggy.debug('ports modified, reconnect system proxy');
          await clashService.setSystemProxy(
            httpPort: newConfig.httpPort!,
            socksPort: newConfig.socksPort!,
          );
        }
        await _configOverridesStore.update(newConfig);
        return right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> changeProxy(
    String selectorName,
    String proxyName,
  ) {
    return exceptionHandler(
      () async {
        await clashRemote.changeProxy(
          selectorName: selectorName,
          proxyName: proxyName,
        );
        return right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> setSystemProxy() {
    return exceptionHandler(
      () async {
        await clashService.setSystemProxy(
          httpPort: _configOverridesSubject.value.httpPort!,
          socksPort: _configOverridesSubject.value.socksPort!,
        );
        // await _isSystemProxyStore.update(true);
        _isSystemProxySubject.value = true;
        await refresh();
        return right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> clearSystemProxy() {
    return exceptionHandler(
      () async {
        await clashService.clearSystemProxy();
        // await _isSystemProxyStore.update(false);
        _isSystemProxySubject.value = false;
        await refresh();
        return right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> closeAllConnections() {
    return exceptionHandler(
      () async {
        await clashRemote.closeAllConnections();
        return right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> closeConnections(String id) {
    return exceptionHandler(
      () async {
        await clashRemote.closeConnections(id);
        return right(unit);
      },
    );
  }

  @override
  Stream<Either<Failure, ClashTraffic>> watchTraffic() {
    return clashRemote.watchTraffic().handleExceptions();
  }

  @override
  Stream<Either<Failure, ClashLog>> watchLogs() {
    return clashRemote.watchLogs(LogLevel.info).handleExceptions();
  }

  @override
  Stream<Either<Failure, ClashConnection>> watchConnections() {
    return clashRemote.watchConnections().handleExceptions();
  }

  @override
  Stream<Either<Failure, ClashConfig>> watchConfigOverrides() {
    return _configOverridesSubject.stream.map((event) => right(event));
  }
}
