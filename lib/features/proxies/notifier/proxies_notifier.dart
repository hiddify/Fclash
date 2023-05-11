import 'dart:async';

import 'package:fclash/core/clash/clash.dart';
import 'package:fclash/features/proxies/notifier/proxies_state.dart';
import 'package:fclash/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class ProxiesNotifier extends Notifier<ProxiesState> {
  static final provider = NotifierProvider<ProxiesNotifier, ProxiesState>(
    ProxyNotifierImpl.new,
  );

  Future<void> init();
  Future<void> changeProxy(String selectorName, String proxyName);
}

class ProxyNotifierImpl extends ProxiesNotifier with AppLogger {
  @override
  ProxiesState build() {
    state = const ProxiesState();
    init();
    return state;
  }

  @override
  Future<void> init() async {
    loggy.debug('initializing');
    ref.listen(
      ClashController.provider.select((value) => value.selectors),
      (_, selectors) {
        loggy.debug('new selectors received');
        state = state.copyWith(selectors: selectors);
      },
      fireImmediately: true,
    );
  }

  @override
  Future<void> changeProxy(String selectorName, String proxyName) {
    return ref
        .read(ClashController.provider.notifier)
        .changeProxy(selectorName, proxyName);
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
