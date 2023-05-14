import 'dart:async';

import 'package:clashify/data/data_providers.dart';
import 'package:clashify/domain/failures.dart';
import 'package:clashify/domain/profiles/profiles.dart';
import 'package:clashify/features/profiles/notifier/profiles_state.dart';
import 'package:clashify/utils/utils.dart';
import 'package:dartx/dartx.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfilesNotifier extends Notifier<ProfilesState> with AppLogger {
  static final provider =
      NotifierProvider<ProfilesNotifier, ProfilesState>(ProfilesNotifier.new);

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
          (l) {
            loggy.warning('failed to receive profiled, $l');
          },
          (profiles) {
            state = state.copyWith(
              profiles: profiles,
              selectedProfile: profiles.firstOrNullWhere((e) => e.active),
            );
          },
        );
      },
    );
  }

  Future<void> selectActiveProfile(String id) async {
    loggy.debug('setting active profile to: $id');
    await _profilesRepo.setAsActive(id).then(
          (value) => value.match(
            (l) {
              loggy.warning('failed to set $id as active profile, $l');
              // propagate error
            },
            (_) => null,
          ),
        );
  }
}
