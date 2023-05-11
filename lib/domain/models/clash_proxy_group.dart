import 'package:dartx/dartx.dart';
import 'package:fclash/domain/enums.dart';
import 'package:fclash/domain/models/clash_proxy.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'clash_proxy_group.freezed.dart';
part 'clash_proxy_group.g.dart';

List<ClashProxy>? _proxiesFromJson(dynamic names) => (names as List<dynamic>?)
    ?.map((e) => ClashProxy(name: e as String))
    .toList();

ProxyType _typeFromJson(dynamic type) =>
    ProxyType.values
        .firstOrNullWhere((e) => e.name == (type as String?)?.toLowerCase()) ??
    ProxyType.unknown;

@freezed
class ClashProxyGroup with _$ClashProxyGroup {
  const ClashProxyGroup._();

  const factory ClashProxyGroup({
    required String name,
    @JsonKey(fromJson: _typeFromJson) required ProxyType type,
    @JsonKey(name: 'all', fromJson: _proxiesFromJson) List<ClashProxy>? proxies,
    String? now,
  }) = _ClashProxyGroup;

  factory ClashProxyGroup.fromJson(Map<String, dynamic> json) =>
      _$ClashProxyGroupFromJson(json);
}
