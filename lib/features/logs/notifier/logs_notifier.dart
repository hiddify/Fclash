import 'package:fclash/features/logs/notifier/logs_state.dart';
import 'package:fclash/services/clash/clash.dart';
import 'package:fclash/services/service_providers.dart';
import 'package:fclash/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LogsNotifier extends Notifier<LogsState> with AppLogger {
  static final provider =
      NotifierProvider<LogsNotifier, LogsState>(LogsNotifier.new);

  @override
  LogsState build() {
    state = const LogsState();
    init();
    return state;
  }

  ClashService get _clash => ref.read(Services.clash);

  Future<void> init() async {
    loggy.debug('initializing');
    _clash.startLogging().listen(
      (event) {
        loggy.debug('log event received: $event');
        state = state.copyWith(logs: [...state.logs, event]);
      },
    );
  }
}
