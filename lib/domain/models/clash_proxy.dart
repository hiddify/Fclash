import 'package:freezed_annotation/freezed_annotation.dart';

part 'clash_proxy.freezed.dart';
part 'clash_proxy.g.dart';

@freezed
class ClashProxy with _$ClashProxy {
  const ClashProxy._();

  const factory ClashProxy({
    required String name,
    // required ProxyType type,
    @JsonKey(includeToJson: false, includeFromJson: false) int? delay,
  }) = _ClashProxy;

  factory ClashProxy.fromJson(Map<String, dynamic> json) =>
      _$ClashProxyFromJson(json);
}
