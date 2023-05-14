import 'package:clashify/data/exception_handler.dart';
import 'package:clashify/data/local/dao/dao.dart';
import 'package:clashify/domain/failures.dart';
import 'package:clashify/domain/profiles/profiles.dart';
import 'package:clashify/services/files_editor_service.dart';
import 'package:clashify/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

// HACK: not complete

class ProfilesRepositoryImpl
    with ExceptionHandler, InfraLogger
    implements ProfilesRepository {
  ProfilesRepositoryImpl({
    required this.profilesDao,
    required this.filesEditor,
    required this.dio,
  });

  final ProfilesDao profilesDao;
  final FilesEditorService filesEditor;
  final Dio dio;

  @override
  Future<Either<Failure, Profile?>> getById(String id) {
    return exceptionHandler(
      () async => right(await profilesDao.getById(id)),
    );
  }

  @override
  Stream<Either<Failure, Profile?>> watchActiveProfile() {
    return profilesDao.watchActiveProfile().handleExceptions();
  }

  @override
  Stream<Either<Failure, List<Profile>>> watchAll() {
    return profilesDao.watchAll().handleExceptions();
  }

  @override
  Future<Either<Failure, Unit>> add(Profile baseProfile) async {
    return exceptionHandler(
      () async {
        final profileAndConfig = await fetch(baseProfile);
        await filesEditor.createOrUpdateConfig(
          baseProfile.id,
          profileAndConfig.second,
        );
        await profilesDao.create(profileAndConfig.first);
        return right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> update(Profile baseProfile) async {
    return exceptionHandler(
      () async {
        final profileAndConfig = await fetch(baseProfile);
        await filesEditor.createOrUpdateConfig(
          baseProfile.id,
          profileAndConfig.second,
        );
        await profilesDao.edit(profileAndConfig.first);
        return right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> setAsActive(String id) async {
    return exceptionHandler(
      () async {
        await profilesDao.setAsActive(id);
        return right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteById(String id) async {
    return exceptionHandler(
      () async {
        await profilesDao.removeById(id);
        await filesEditor.deleteConfig(id);
        return right(unit);
      },
    );
  }

  @visibleForTesting
  Future<Tuple2<Profile, String>> fetch(Profile profile) async {
    try {
      final response = await dio.get<String>(profile.url);
      loggy.debug(response);
      loggy.debug(response.data.runtimeType);
      if (response.statusCode != 200 || response.data == null) {
        throw Exception();
      }
      loggy.debug(response.headers);
      final subInfoString =
          response.headers.map['subscription-userinfo']?.first;
      final subscriptionInfo = subInfoString != null
          ? SubscriptionInfo.fromResponseHeader(subInfoString)
          : null;
      final newProfile = profile.copyWith(subInfo: subscriptionInfo);
      loggy.debug('sub info= $subscriptionInfo');
      return Tuple2(newProfile, response.data!);
    } catch (e) {
      throw Exception();
    }
  }
}
