import 'package:fclash/domain/models/clash_connection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'connections_state.freezed.dart';

@freezed
class ConnectionsState with _$ConnectionsState {
  const ConnectionsState._();

  const factory ConnectionsState({
    @Default(ClashConnection()) ClashConnection connection,
  }) = _ConnectionsState;
}
