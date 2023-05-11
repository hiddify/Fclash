import 'package:fclash/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'clash_config.freezed.dart';
part 'clash_config.g.dart';

@freezed
class ClashConfig with _$ClashConfig {
  const ClashConfig._();

  @JsonSerializable(includeIfNull: false)
  const factory ClashConfig({
    @JsonKey(name: 'port') int? httpPort,
    @JsonKey(name: 'socks-port') int? socksPort,
    @JsonKey(name: 'redir-port') int? redirectPort,
    @JsonKey(name: 'tproxy-port') int? tproxyPort,
    @JsonKey(name: 'mixed-port') int? mixedPort,
    @JsonKey(name: 'authentication') List<String>? authentication,
    @JsonKey(name: 'allow-lan') bool? allowLan,
    @JsonKey(name: 'bind-address') String? bindAddress,
    @JsonKey(name: 'mode') RouterMode? mode,
    @JsonKey(name: 'log-level') LogLevel? logLevel,
    @JsonKey(name: 'ipv6') bool? ipv6,
  }) = _ClashConfig;

  factory ClashConfig.fromJson(Map<String, dynamic> json) =>
      _$ClashConfigFromJson(json);
}
