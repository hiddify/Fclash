import 'package:fclash/domain/models/clash_proxy_group.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'proxies_state.freezed.dart';

@freezed
class ProxiesState with _$ProxiesState {
  const ProxiesState._();

  const factory ProxiesState({
    @Default([]) List<ClashProxyGroup> selectors,
  }) = _ProxiesState;
}
