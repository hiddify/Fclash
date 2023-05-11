import 'package:fclash/data/data_providers.dart';
import 'package:fclash/data/prefs_store.dart';
import 'package:fclash/domain/models/clash_config.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class Pref {
  static final isSystemProxy = Provider(
    (ref) => SimplePrefStore(
      prefs: ref.read(Data.preferences),
      key: 'is_system_proxy',
      defaultValue: false,
    ),
  );

  static final activeProfileId = Provider(
    (ref) => SimplePrefStore<String>(
      prefs: ref.read(Data.preferences),
      key: 'active_profile_id',
      defaultValue: '',
    ),
  );

  static final configOverrides = Provider(
    (ref) => SimplePrefStore(
      prefs: ref.read(Data.preferences),
      key: 'config_overrides',
      defaultValue: const ClashConfig(
        httpPort: 12346,
        socksPort: 12347,
        mixedPort: 12348,
      ),
      mapFrom: ClashConfig.fromJson,
      mapTo: (item) => item.toJson(),
    ),
  );
}
