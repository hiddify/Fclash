import 'package:clashify/domain/failures.dart';
import 'package:clashify/domain/profiles/profiles.dart';
import 'package:fpdart/fpdart.dart';

abstract class ProfilesRepository {
  Future<Either<Failure, Profile?>> getById(String id);

  Stream<Either<Failure, Profile?>> watchActiveProfile();

  Stream<Either<Failure, List<Profile>>> watchAll();

  Future<Either<Failure, Unit>> add(Profile baseProfile);

  Future<Either<Failure, Unit>> update(Profile baseProfile);

  Future<Either<Failure, Unit>> setAsActive(String id);

  Future<Either<Failure, Unit>> deleteById(String id);
}
