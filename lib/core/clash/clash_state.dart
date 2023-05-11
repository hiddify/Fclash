import 'package:fclash/domain/enums.dart';
import 'package:fclash/domain/models/clash_config.dart';
import 'package:fclash/domain/models/clash_proxy_group.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'clash_state.freezed.dart';

@freezed
class ClashState with _$ClashState {
  const ClashState._();

  const factory ClashState({
    @Default('config.yaml') String activeConfigName,
    @Default(ClashConfig()) ClashConfig overrides,
    @Default([]) List<ClashProxyGroup> selectors,
    @Default(false) bool isSystemProxy,
    @Default(RouterMode.direct) RouterMode mode,
  }) = _ClashState;
}
