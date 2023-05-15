import 'package:clashify/domain/profiles/profiles.dart';
import 'package:clashify/features/common/common.dart';
import 'package:clashify/utils/utils.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    @Default(ValueState.loading())
        ValueState<Profile> activeProfile,
    @Default(SystemProxyState.disconnected(null))
        SystemProxyState proxyConnection,
  }) = _HomeState;
}
