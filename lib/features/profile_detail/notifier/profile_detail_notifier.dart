// import 'dart:async';

// import 'package:dartx/dartx.dart';
// import 'package:clashify/data/data_providers.dart';
// import 'package:clashify/domain/profiles/profiles.dart';
// import 'package:clashify/features/profile_detail/notifier/profile_detail_state.dart';
// import 'package:clashify/utils/utils.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:uuid/uuid.dart';

// class ProfileDetailNotifier
//     extends AutoDisposeFamilyAsyncNotifier<ProfileDetailState, String>
//     with AppLogger {
//   static final provider = AutoDisposeAsyncNotifierProviderFamily<
//       ProfileDetailNotifier, ProfileDetailState, String>(
//     ProfileDetailNotifier.new,
//   );

//   @override
//   FutureOr<ProfileDetailState> build(String arg) async {
//     if (arg == 'new') {
//       return ProfileDetailState(
//         profile: Profile(
//           id: const Uuid().v4(),
//           active: false,
//           name: '',
//           url: '',
//           lastUpdate: DateTime.now(),
//         ),
//       );
//     }
//     final profileOrNull = await _profilesRepo.getById(arg);
//     if (profileOrNull == null) {
//       throw Exception();
//     }
//     return ProfileDetailState(profile: profileOrNull);
//   }

//   ProfilesRepository get _profilesRepo => ref.read(Repository.profiles);

//   void setField({
//     String? name,
//     String? url,
//   }) {
//     if (!state.hasValue) return;
//     final profile = state.requireValue.profile;
//     state = AsyncData(
//       state.requireValue.copyWith(
//         profile: profile.copyWith(
//           name: name ?? profile.name,
//           url: url ?? profile.url,
//         ),
//       ),
//     );
//   }

//   Future<void> save() async {
//     if (!state.hasValue) return;
//     loggy.debug('saving profile');
//     final profile = state.requireValue.profile;
//     if (profile.name.isBlank || profile.url.isBlank) {
//       loggy.debug('invalid arguments');
//       state = AsyncData(state.requireValue.copyWith(showErrorMessages: true));
//       return;
//     }
//     state = AsyncData(
//       state.requireValue.copyWith(save: const MutationState.inProgress()),
//     );
//     if (state.requireValue.isEditing) {
//       loggy.debug('updating profile');
//       _profilesRepo.update(profile);
//       state = AsyncData(
//         state.requireValue.copyWith(save: const MutationState.success()),
//       );
//     } else {
//       await _createProfile(profile);
//     }
//   }

//   Future<void> _createProfile(Profile profile) async {
//     loggy.debug('adding profile with url: ${profile.url}');
//     try {
//       await _profilesRepo.add(profile);
//       state = AsyncData(
//         state.requireValue.copyWith(save: const MutationState.success()),
//       );
//     } catch (e) {
//       loggy.warning('error adding profile: $e');
//       state = AsyncData(
//         state.requireValue.copyWith(
//           save: MutationState.failure(e),
//           showErrorMessages: true,
//         ),
//       );
//     }
//   }
// }

import 'dart:async';

import 'package:clashify/data/data_providers.dart';
import 'package:clashify/domain/failures.dart';
import 'package:clashify/domain/profiles/profiles.dart';
import 'package:clashify/features/profile_detail/notifier/profile_detail_state.dart';
import 'package:clashify/utils/utils.dart';
import 'package:dartx/dartx.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

class ProfileDetailNotifier extends AutoDisposeFamilyAsyncNotifier<
    ProfileDetailState, Tuple2<String, String>> with AppLogger {
  static final provider = AutoDisposeAsyncNotifierProviderFamily<
      ProfileDetailNotifier, ProfileDetailState, Tuple2<String, String>>(
    ProfileDetailNotifier.new,
  );

  @override
  FutureOr<ProfileDetailState> build(Tuple2<String, String> arg) async {
    if (profileId == 'new') {
      return ProfileDetailState(
        profile: Profile(
          id: const Uuid().v4(),
          active: true,
          name: '',
          url: arg.second,
          lastUpdate: DateTime.now(),
        ),
      );
    }
    final failureOrProfile = await _profilesRepo.getById(profileId);
    return failureOrProfile.match(
      (l) {
        loggy.warning('failed to load profile, $l');
        throw l;
      },
      (profile) {
        if (profile == null) {
          loggy.warning('profile with id[$profileId] does not exist');
          throw const DatabaseFailure.itemNotFound();
        }
        return ProfileDetailState(profile: profile);
      },
    );
  }

  String get profileId => arg.first;
  ProfilesRepository get _profilesRepo => ref.read(Repository.profiles);

  void setField({
    String? name,
    String? url,
  }) {
    if (!state.hasValue) return;
    final profile = state.requireValue.profile;
    state = AsyncData(
      state.requireValue.copyWith(
        profile: profile.copyWith(
          name: name ?? profile.name,
          url: url ?? profile.url,
        ),
      ),
    );
  }

  Future<void> save() async {
    if (!state.hasValue) return;
    loggy.debug('saving profile');
    final profile = state.requireValue.profile;
    if (profile.name.isBlank || profile.url.isBlank) {
      loggy.debug('invalid arguments');
      state = AsyncData(state.requireValue.copyWith(showErrorMessages: true));
      return;
    }
    state = AsyncData(
      state.requireValue.copyWith(save: const MutationState.inProgress()),
    );
    if (state.requireValue.isEditing) {
      loggy.debug('updating profile');
      _profilesRepo.update(profile);
      state = AsyncData(
        state.requireValue.copyWith(save: const MutationState.success()),
      );
    } else {
      await _createProfile(profile);
    }
  }

  Future<void> _createProfile(Profile profile) async {
    loggy.debug('adding profile with url: ${profile.url}');

    final result = await _profilesRepo.add(profile);
    result.fold(
      (l) {
        loggy.warning('failed to create profile, $l');
        state = AsyncData(
          state.requireValue.copyWith(
            save: MutationState.failure(l),
            showErrorMessages: true,
          ),
        );
      },
      (_) {
        state = AsyncData(
          state.requireValue.copyWith(save: const MutationState.success()),
        );
      },
    );
  }
}
