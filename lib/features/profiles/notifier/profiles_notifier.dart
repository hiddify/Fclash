import 'package:dartx/dartx.dart';
import 'package:fclash/data/prefs_providers.dart';
import 'package:fclash/data/prefs_store.dart';
import 'package:fclash/data/profiles_store.dart';
import 'package:fclash/domain/models/profile.dart';
import 'package:fclash/features/profiles/notifier/profiles_state.dart';
import 'package:fclash/features/proxies/notifier/notifier.dart';
import 'package:fclash/services/service_providers.dart';
import 'package:fclash/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfilesNotifier extends Notifier<ProfilesState> with AppLogger {
  static final provider =
      NotifierProvider<ProfilesNotifier, ProfilesState>(ProfilesNotifier.new);

  @override
  ProfilesState build() {
    state = const ProfilesState();
    init();
    return state;
  }

  SimplePrefStore<String> get _activeProfileId =>
      ref.read(Pref.activeProfileId);

  Future<void> init() async {
    loggy.debug('initializing');
    final activeProfileId = await _activeProfileId.get();
    Profile? activeProfile;
    if (activeProfileId.isNotBlank) {
      activeProfile =
          await ref.read(ProfileStore.provider.notifier).get(activeProfileId);
    }
    state = state.copyWith(selectedProfile: activeProfile);
    ref.listen(
      ProfileStore.provider,
      (_, profiles) {
        loggy.debug('new profiles length= ${profiles.length}');
        state = state.copyWith(
          profiles: profiles.toList(),
        );
      },
      fireImmediately: true,
    );
  }

  Future<void> selectActiveProfile(String id) async {
    loggy.debug('selecting active profile id: $id');
    final newActiveProfile = state.profiles.firstOrNullWhere((e) => e.id == id);
    if (newActiveProfile == null) {
      loggy.warning("profile with id: $id doesn't exist");
      return;
    }
    final result = await ref.read(Services.clash).setConfigById(id);
    if (result) {
      await _activeProfileId.update(id);
      state = state.copyWith(selectedProfile: newActiveProfile);
      ref.invalidate(ProxiesNotifier.provider);
    } else {
      loggy.warning('failed to change config');
    }
  }
}
