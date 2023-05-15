import 'package:clashify/domain/failures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_proxy_state.freezed.dart';

@freezed
class SystemProxyState with _$SystemProxyState {
  const SystemProxyState._();

  const factory SystemProxyState.disconnected(Failure? failedToConnect) =
      _Disconnected;
  const factory SystemProxyState.switching(bool previouslyConnected) =
      _Connecting;
  const factory SystemProxyState.connected(Failure? failedToDisconnect) =
      _Connected;

  bool get isConnected {
    return when(
      disconnected: (_) => false,
      switching: (previouslyConnected) => previouslyConnected,
      connected: (_) => true,
    );
  }
}
