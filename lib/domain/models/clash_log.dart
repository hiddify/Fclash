import 'package:fclash/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'clash_log.freezed.dart';
part 'clash_log.g.dart';

@freezed
class ClashLog with _$ClashLog {
  const ClashLog._();

  const factory ClashLog({
    @JsonKey(name: 'LogLevel') required LogLevel level,
    @JsonKey(name: 'Payload') required String message,
    @JsonKey(defaultValue: DateTime.now) required DateTime time,
  }) = _ClashLog;

  factory ClashLog.fromJson(Map<String, dynamic> json) =>
      _$ClashLogFromJson(json);
}
