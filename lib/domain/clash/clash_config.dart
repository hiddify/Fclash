import 'package:clashify/domain/enums.dart';
import 'package:fpdart/fpdart.dart';
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

  ClashConfig patch(ClashConfigPatch patch) {
    return copyWith(
      httpPort: patch.httpPort?.fold(() => null, (t) => t) ?? httpPort,
      socksPort: patch.socksPort?.fold(() => null, (t) => t) ?? socksPort,
      redirectPort:
          patch.redirectPort?.fold(() => null, (t) => t) ?? redirectPort,
      tproxyPort: patch.tproxyPort?.fold(() => null, (t) => t) ?? tproxyPort,
      mixedPort: patch.mixedPort?.fold(() => null, (t) => t) ?? mixedPort,
      authentication:
          patch.authentication?.fold(() => null, (t) => t) ?? authentication,
      allowLan: patch.allowLan?.fold(() => null, (t) => t) ?? allowLan,
      bindAddress: patch.bindAddress?.fold(() => null, (t) => t) ?? bindAddress,
      mode: patch.mode?.fold(() => null, (t) => t) ?? mode,
      logLevel: patch.logLevel?.fold(() => null, (t) => t) ?? logLevel,
      ipv6: patch.ipv6?.fold(() => null, (t) => t) ?? ipv6,
    );
  }

  factory ClashConfig.fromJson(Map<String, dynamic> json) =>
      _$ClashConfigFromJson(json);
}

@freezed
class ClashConfigPatch with _$ClashConfigPatch {
  const ClashConfigPatch._();

  @JsonSerializable(includeIfNull: false)
  const factory ClashConfigPatch({
    Option<int>? httpPort,
    Option<int>? socksPort,
    Option<int>? redirectPort,
    Option<int>? tproxyPort,
    Option<int>? mixedPort,
    Option<List<String>>? authentication,
    Option<bool>? allowLan,
    Option<String>? bindAddress,
    Option<RouterMode>? mode,
    Option<LogLevel>? logLevel,
    Option<bool>? ipv6,
  }) = _ClashConfigPatch;
}
