import 'package:clashify/domain/clash/clash.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'logs_state.freezed.dart';

@freezed
class LogsState with _$LogsState {
  const LogsState._();

  const factory LogsState({
    @Default([]) List<ClashLog> logs,
  }) = _LogsState;
}
