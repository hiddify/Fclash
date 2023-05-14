import 'package:clashify/features/logs/notifier/logs_state.dart';
import 'package:clashify/utils/utils.dart';
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

  Future<void> init() async {
    loggy.debug('initializing');
    // _clash.startLogging().listen(
    //   (event) {
    //     loggy.debug('log event received: $event');
    //     state = state.copyWith(logs: [...state.logs, event]);
    //   },
    // );
  }
}
