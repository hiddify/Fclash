import 'dart:async';

import 'package:clashify/data/data_providers.dart';
import 'package:clashify/domain/clash/clash.dart';
import 'package:clashify/domain/profiles/profiles.dart';
import 'package:clashify/features/common/common.dart';
import 'package:clashify/features/home/notifier/home_state.dart';
import 'package:clashify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeNotifier extends Notifier<HomeState> with AppLogger {
  static final provider =
      NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

  @override
  HomeState build() {
    state = const HomeState();
    ref.onDispose(
      () {
        loggy.debug('disposing');
        _listener?.cancel();
      },
    );
    init();
    return state;
  }

  ClashFacade get _clash => ref.read(Facade.clash);
  ProfilesRepository get _profiles => ref.read(Repository.profiles);

  StreamSubscription? _listener;

  Future<void> init() async {
    loggy.debug('initializing');
    _listener = _profiles.watchActiveProfile().listen(
      (failureOrActiveProfile) {
        failureOrActiveProfile.match(
          (f) {
            loggy.warning('failed to receive active profile: $f');
            state = state.copyWith(activeProfile: ValueState.failure(f));
          },
          (profileOrNull) {
            state = state.copyWith(
              activeProfile: profileOrNull == null
                  ? const ValueState.initial()
                  : ValueState.data(profileOrNull),
            );
          },
        );
      },
    );
  }

  Future<void> toggleConnection() async {
    final proxyState = await state.proxyConnection.when(
      connected: (_) async {
        loggy.debug('disconnecting proxy');
        state = state.copyWith(
          proxyConnection: const SystemProxyState.switching(true),
        );
        return _clash.clearSystemProxy().then(
              (value) => value.fold(
                (f) {
                  loggy.warning('failed to disconnect proxy: $f');
                  return SystemProxyState.connected(f);
                },
                (_) => const SystemProxyState.disconnected(null),
              ),
            );
      },
      disconnected: (_) {
        loggy.debug('connecting proxy');
        state = state.copyWith(
          proxyConnection: const SystemProxyState.switching(false),
        );
        return _clash.setSystemProxy().then(
              (value) => value.fold(
                (f) {
                  loggy.warning('failed to connect proxy: $f');
                  return SystemProxyState.disconnected(f);
                },
                (_) => const SystemProxyState.connected(null),
              ),
            );
      },
      switching: (_) => null,
    );
    if (proxyState != null) state = state.copyWith(proxyConnection: proxyState);
  }
}
