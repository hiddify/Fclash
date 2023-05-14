import 'dart:async';

import 'package:clashify/data/data_providers.dart';
import 'package:clashify/domain/clash/clash.dart';
import 'package:clashify/features/proxies/notifier/proxies_state.dart';
import 'package:clashify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class ProxiesNotifier extends Notifier<ProxiesState> {
  static final provider = NotifierProvider<ProxiesNotifier, ProxiesState>(
    ProxyNotifierImpl.new,
  );

  Future<void> init();
  Future<void> changeProxy(String selectorName, String proxyName);
  Future<void> setSystemProxy();
  Future<void> clearSystemProxy();
}

class ProxyNotifierImpl extends ProxiesNotifier with AppLogger {
  @override
  ProxiesState build() {
    state = const ProxiesState();
    init();
    return state;
  }

  ClashFacade get _clash => ref.read(Facade.clash);

  @override
  Future<void> init() async {
    loggy.debug('initializing');
    _clash.watchSelectors().listen((event) {
      event.map((a) => state = state.copyWith(selectors: a));
    });
  }

  @override
  Future<void> changeProxy(String selectorName, String proxyName) async {
    await _clash.changeProxy(selectorName, proxyName);
  }

  @override
  Future<void> setSystemProxy() async {
    await _clash.setSystemProxy().then(
          (value) => value.match(
            (f) {
              loggy.debug('failed to set as system proxy');
            },
            (_) {
              state = state.copyWith(isSystemProxy: true);
            },
          ),
        );
  }

  @override
  Future<void> clearSystemProxy() async {
    await _clash.clearSystemProxy().then(
          (value) => value.match(
            (f) {
              loggy.debug('failed to clear system proxy');
            },
            (_) {
              state = state.copyWith(isSystemProxy: false);
            },
          ),
        );
  }

  // Future<void> testDelays(ClashProxyGroup group) async {
  //   loggy.debug('testing delay for ${group.name}');
  //   if (group.proxies == null) return;
  //   await for (final delay in ref
  //       .read(Services.clash)
  //       .testProxies(group.proxies!.map((e) => e.name))) {
  //     final data = state.requireValue;
  //   }
  // }
}
