import 'package:fclash/features/connections/notifier/connections_state.dart';
import 'package:fclash/services/clash/clash.dart';
import 'package:fclash/services/service_providers.dart';
import 'package:fclash/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ConnectionsNotifier extends Notifier<ConnectionsState> with AppLogger {
  static final provider =
      NotifierProvider<ConnectionsNotifier, ConnectionsState>(
    ConnectionsNotifier.new,
  );

  @override
  ConnectionsState build() {
    state = const ConnectionsState();
    init();
    return state;
  }

  ClashService get _clash => ref.read(Services.clash);

  Future<void> init() async {
    loggy.debug('initializing');
    _clash.watchConnections().listen(
      (event) {
        loggy.debug('connection event received');
        state = state.copyWith(connection: event);
      },
    );
  }

  Future<void> closeAll() async {
    loggy.debug('closing all connections');
    await _clash.closeAllConnections();
  }
}
