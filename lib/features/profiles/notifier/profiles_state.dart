import 'package:fclash/domain/models/profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profiles_state.freezed.dart';

@freezed
class ProfilesState with _$ProfilesState {
  const ProfilesState._();

  const factory ProfilesState({
    Profile? selectedProfile,
    @Default([]) List<Profile> profiles,
  }) = _ProfilesState;
}
