import 'package:dartx/dartx.dart';
import 'package:fclash/core/clash/clash_platform_coordinator.dart';
import 'package:fclash/core/clash/clash_state.dart';
import 'package:fclash/data/prefs_providers.dart';
import 'package:fclash/domain/enums.dart';
import 'package:fclash/services/clash/clash.dart';
import 'package:fclash/services/service_providers.dart';
import 'package:fclash/utils/utils.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';

abstract class ClashController extends Notifier<ClashState> {
  static final provider =
      NotifierProvider<ClashController, ClashState>(ClashControllerImpl.new);

  Future<void> init();
  Future<void> setSystemProxy();
  Future<void> clearSystemProxy();
  Future<void> changeOverrides({
    Option<int>? httpPort,
    Option<RouterMode>? mode,
  });
  Future<void> changeProxy(String selectorName, String proxyName);
  Future<void> changeMode();
}

class ClashControllerImpl extends ClashController
    with ClashPlatformCoordinator, TrayListener, AppLogger, AppLogger {
  @override
  ClashState build() {
    return const ClashState();
  }

  late final _overridesStore = ref.read(Pref.configOverrides);
  late final _activeProfileIdStore = ref.read(Pref.activeProfileId);
  late final _isSystemProxyStore = ref.read(Pref.isSystemProxy);

  ClashService get _clash => ref.read(Services.clash);

  @override
  Future<void> init() async {
    loggy.debug('initializing');
    final activeProfileId = await _activeProfileIdStore.get();
    final configFileName =
        '${activeProfileId.isBlank ? 'config' : activeProfileId}.yaml';
    final overrides = await _overridesStore.get();
    await _clash.init(configFileName, overrides);
    state = state.copyWith(overrides: overrides);
    // ref.listenSelf(
    //   (previous, next) {
    //     evaluate();
    //   },
    // );
    await startCoordination();
    // _updateSelectors();
    await evaluate();
  }

  Future<void> evaluate() async {
    await _updateSelectors();
    await updateSystemTray(
      configPath: state.activeConfigName, // test
      selectors: state.selectors,
      isSystemProxy: state.isSystemProxy,
    );
  }

  Future<void> _updateSelectors() async {
    final config = await _clash.getCurrentConfig();
    final groups = await _clash.getProxyGroups();
    var selectors = groups.where((e) => e.type == ProxyType.selector);
    switch (config.mode) {
      case RouterMode.global:
        selectors = selectors.where((e) => e.name.toLowerCase() == 'global');
        break;
      case RouterMode.direct:
        selectors = [];
        break;
      default:
    }
    state = state.copyWith(
      mode: config.mode ?? state.mode,
      selectors: selectors.toList(),
    );
  }

  @override
  Future<void> changeOverrides({
    Option<int>? httpPort,
    Option<RouterMode>? mode,
  }) async {
    final config = state.overrides;
    final newConfig = state.overrides.copyWith(
      httpPort: httpPort?.fold(() => null, (t) => t) ?? config.httpPort,
      mode: mode?.fold(() => null, (t) => t) ?? config.mode,
    );
    loggy.debug('changing config: $newConfig');
    await _clash.changeConfigFields(newConfig);
    if (state.isSystemProxy && (httpPort?.isSome() ?? false)) {
      loggy.debug('ports modified, reconnect system proxy');
      await setSystemProxy();
    }
    state = state.copyWith(overrides: newConfig);
    evaluate();
  }

  @override
  Future<void> setSystemProxy() async {
    loggy.debug('setting as system proxy');
    await _clash.setSystemProxy(
      httpPort: state.overrides.httpPort!,
      socksPort: state.overrides.socksPort!,
    );
    await _isSystemProxyStore.update(true);
    state = state.copyWith(isSystemProxy: true);
    await evaluate();
  }

  @override
  Future<void> clearSystemProxy() async {
    loggy.debug('clearing system proxy');
    await _clash.clearSystemProxy();
    await _isSystemProxyStore.update(false);
    state = state.copyWith(isSystemProxy: false);
    evaluate();
  }

  @override
  Future<void> changeProxy(String selectorName, String proxyName) async {
    loggy.debug('changing proxy: $selectorName <=> $proxyName');
    final result = await _clash.changeProxy(selectorName, proxyName);
    loggy.debug('proxy change result: $result');
    if (result) await evaluate();
  }

  @override
  Future<void> changeMode() {
    // TODO: implement changeMode
    throw UnimplementedError();
  }
}
