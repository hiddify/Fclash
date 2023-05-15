import 'package:clashify/domain/profiles/profiles.dart';
import 'package:clashify/utils/utils.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profiles_state.freezed.dart';

@freezed
class ProfilesState with _$ProfilesState {
  const ProfilesState._();

  const factory ProfilesState({
    @Default(ValueState.loading()) ValueState<List<Profile>> profiles,
    @Default(MutationState.initial()) MutationState selectProfile,
  }) = _ProfilesState;
}
