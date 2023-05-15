import 'dart:async';

import 'package:clashify/data/data_providers.dart';
import 'package:clashify/domain/failures.dart';
import 'package:clashify/domain/profiles/profiles.dart';
import 'package:clashify/features/profiles/notifier/profiles_state.dart';
import 'package:clashify/utils/utils.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfilesNotifier extends AutoDisposeNotifier<ProfilesState>
    with AppLogger {
  static final provider =
      NotifierProvider.autoDispose<ProfilesNotifier, ProfilesState>(
    ProfilesNotifier.new,
  );

  @override
  ProfilesState build() {
    state = const ProfilesState();
    init();
    ref.onDispose(
      () {
        _listener?.cancel();
      },
    );
    return state;
  }

  ProfilesRepository get _profilesRepo => ref.read(Repository.profiles);
  StreamSubscription<Either<Failure, List<Profile>>>? _listener;

  Future<void> init() async {
    loggy.debug('initializing');
    _listener = _profilesRepo.watchAll().listen(
      (failureOrProfiles) {
        failureOrProfiles.fold(
          (f) {
            loggy.warning('failed to receive profiles, $f');
            state = state.copyWith(profiles: ValueState.failure(f));
          },
          (profiles) {
            state = state.copyWith(
              profiles: ValueState.data(profiles),
            );
          },
        );
      },
    );
  }

  Future<void> selectActiveProfile(String id) async {
    if (state.selectProfile.isInProgress) return;
    loggy.debug('changing active profile to: $id');
    state = state.copyWith(selectProfile: const MutationState.inProgress());
    await _profilesRepo.setAsActive(id).then(
          (value) => value.match(
            (f) {
              loggy.warning('failed to set $id as active profile, $f');
              state = state.copyWith(selectProfile: MutationState.failure(f));
            },
            (_) {
              state =
                  state.copyWith(selectProfile: const MutationState.success());
            },
          ),
        );
  }
}
