import 'package:fclash/data/data_store.dart';
import 'package:fclash/domain/models/profile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileStore extends ItemsDataStore<Profile> {
  static final provider =
      NotifierProvider<ProfileStore, List<Profile>>(ProfileStore.new);

  @override
  String keyGen(String id) => 'profile_$id';

  @override
  Profile mapFrom(Map<String, dynamic> json) => Profile.fromJson(json);

  @override
  Map<String, dynamic> mapTo(Profile item) => item.toJson();
}
