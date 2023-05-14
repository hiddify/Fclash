import 'package:clashify/data/facade/facade.dart';
import 'package:clashify/data/local/dao/dao.dart';
import 'package:clashify/data/local/database.dart';
import 'package:clashify/data/remote/remote.dart';
import 'package:clashify/data/repository/repository.dart';
import 'package:clashify/domain/clash/clash.dart';
import 'package:clashify/domain/profiles/profiles.dart';
import 'package:clashify/services/service_providers.dart';
import 'package:clashify/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Data {
  static final database = Provider<AppDatabase>(
    (_) => AppDatabase.connect(),
  );

  /// shared preferences instance
  ///
  /// **must be overridden in bootstrapping process**
  static final sharedPreferences = Provider<SharedPreferences>(
    (_) => throw UnimplementedError('sharedPreferences must be overridden'),
  );

  // TODO: improve
  static final dio = Provider(
    (_) => Dio(),
  );

  static final preferences = Provider<Preferences>(
    (ref) => Preferences.basic(
      sharedPreferences: ref.read(sharedPreferences),
    ),
  );

  static final profilesDao = Provider((ref) => ProfilesDao(ref.read(database)));

  static final clashRemote = Provider<ClashDataSource>(
    (_) => ClashDataSourceImpl(),
  );
}

abstract class Repository {
  static final profiles = Provider<ProfilesRepository>(
    (ref) => ProfilesRepositoryImpl(
      profilesDao: ref.read(Data.profilesDao),
      filesEditor: ref.read(Services.filesEditor),
      dio: ref.read(Data.dio),
    ),
  );
}

abstract class Facade {
  static final clash = Provider<ClashFacade>(
    (ref) => ClashFacadeImpl(
      clashRemote: ref.read(Data.clashRemote),
      clashService: ref.read(Services.clash),
      preferences: ref.read(Data.preferences),
      filesEditor: ref.read(Services.filesEditor),
      profilesRepo: ref.read(Repository.profiles),
    ),
  );
}
