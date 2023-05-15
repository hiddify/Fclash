import 'dart:async';

import 'package:clashify/data/data_providers.dart';
import 'package:clashify/domain/clash/clash.dart';
import 'package:clashify/features/logs/notifier/logs_state.dart';
import 'package:clashify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO: possibly keep alive
class LogsNotifier extends AutoDisposeNotifier<LogsState> with AppLogger {
  static final provider =
      NotifierProvider.autoDispose<LogsNotifier, LogsState>(LogsNotifier.new);

  @override
  LogsState build() {
    state = const LogsState();
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
  StreamSubscription? _listener;

  Future<void> init() async {
    loggy.debug('initializing');
    _listener = _clash.watchLogs().listen(
      (event) {
        event.fold(
          (f) {
            loggy.warning('failed to watch logs: $f');
            state = state.copyWith(load: MutationState.failure(f));
          },
          (newLog) {
            state = state.copyWith(
              logs: [...state.logs, newLog],
              load: const MutationState.success(),
            );
          },
        );
      },
    );
  }
}
