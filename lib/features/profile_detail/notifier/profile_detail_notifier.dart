import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:fclash/data/data_providers.dart';
import 'package:fclash/data/profiles_store.dart';
import 'package:fclash/domain/models/profile.dart';
import 'package:fclash/features/profile_detail/notifier/profile_detail_state.dart';
import 'package:fclash/services/clash/clash.dart';
import 'package:fclash/services/service_providers.dart';
import 'package:fclash/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ProfileDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<ProfileDetailState, String>
    with AppLogger {
  static final provider = AutoDisposeAsyncNotifierProviderFamily<
      ProfileDetailNotifier, ProfileDetailState, String>(
    ProfileDetailNotifier.new,
  );

  @override
  FutureOr<ProfileDetailState> build(String arg) async {
    if (arg == 'new') {
      return ProfileDetailState(
        profile: Profile(
          id: const Uuid().v4(),
          name: '',
          url: '',
          lastUpdate: DateTime.now(),
        ),
      );
    }
    final profileOrNull = await _store.get(arg);
    if (profileOrNull == null) {
      throw Exception();
    }
    return ProfileDetailState(profile: profileOrNull);
  }

  ProfileStore get _store => ref.read(ProfileStore.provider.notifier);
  Dio get _dio => ref.read(Data.dio);
  ClashService get _clash => ref.read(Services.clash);

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
        state.requireValue.copyWith(save: const MutationState.inProgress()),);
    if (state.requireValue.isEditing) {
      loggy.debug('updating profile');
      _store.createOrUpdate(profile.id, profile);
      state = AsyncData(
          state.requireValue.copyWith(save: const MutationState.success()),);
    } else {
      await _createProfile();
    }
  }

  Future<void> _createProfile() async {
    loggy.debug('adding profile with url: ${state.requireValue.profile.url}');
    var syncState = state.requireValue;
    final configFileName = "${syncState.profile.id}.yaml";
    final supportDir = await getApplicationSupportDirectory();
    final dir = Directory(join(supportDir.path, "clash"));
    final newConfigFullPath = join(dir.path, configFileName);
    loggy.debug('new config full path: $newConfigFullPath');
    try {
      final uri = Uri.tryParse(syncState.profile.url);
      loggy.debug('profile uri: $uri');
      final response = await _dio.downloadUri(uri!, newConfigFullPath,
          onReceiveProgress: (i, t) {
        loggy.debug("$i/$t");
      },);
      loggy.debug('profile fetch response: $response');
      // final fetchWasSuccessful = response.statusCode == 200;
      final file = File(newConfigFullPath);
      if (file.existsSync() &&
          await _clash.validateConfigByPath(newConfigFullPath)) {
        _store.createOrUpdate(syncState.profile.id, syncState.profile);
        syncState = syncState.copyWith(save: const MutationState.success());
      } else {
        syncState = syncState.copyWith(
          // TODO: replace
          save: const MutationState.failure(''),
          showErrorMessages: true,
        );
      }
    } catch (e) {
      loggy.warning('error fetching profile: $e');
      syncState = syncState.copyWith(
        save: MutationState.failure(e),
        showErrorMessages: true,
      );
    }
    state = AsyncData(syncState);
  }
}
