import 'package:clashify/core/prefs/locale/locale.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';
part 'failures.g.dart';

mixin Failure {
  String present(TranslationsEn t);
}

@freezed
class AppFailure with _$AppFailure, Failure {
  const AppFailure._();

  const factory AppFailure.network(NetworkFailure failure) = Network;
  const factory AppFailure.database(DatabaseFailure failure) = Database;
  const factory AppFailure.parser(ParserFailure failure) = Parser;
  const factory AppFailure.other(Object exception) = Other;

  factory AppFailure.fromJson(Map<String, dynamic> json) =>
      _$AppFailureFromJson(json);

  @override
  String present(TranslationsEn t) {
    return when(
      network: (failure) => failure.present(t),
      database: (failure) => failure.present(t),
      parser: (failure) => failure.present(t),
      // TODO: replace placeholder
      other: (exception) => 'other placeholder',
    );
  }
}

@freezed
class NetworkFailure with _$NetworkFailure, Failure {
  const NetworkFailure._();

  const factory NetworkFailure.unexpected() = NetworkUnexpected;
  const factory NetworkFailure.noInternetConnection() = NoInternetConnection;
  const factory NetworkFailure.requestCancelled() = RequestCancelled;
  const factory NetworkFailure.notFound() = NotFound;
  const factory NetworkFailure.unauthorisedRequest() = UnauthorisedRequest;
  const factory NetworkFailure.badRequest() = BadRequest;
  const factory NetworkFailure.sendTimeout() = SendTimeout;
  const factory NetworkFailure.requestTimeout() = RequestTimeout;
  const factory NetworkFailure.conflict() = Conflict;
  const factory NetworkFailure.internalServerError() = InternalServerError;
  const factory NetworkFailure.serviceUnavailable() = ServiceUnavailable;

  factory NetworkFailure.fromJson(Map<String, dynamic> json) =>
      _$NetworkFailureFromJson(json);

  @override
  String present(TranslationsEn t) {
    if (this is NetworkUnexpected) return t.failure.unexpected;
    final path =
        toString().replaceAll('NetworkFailure.', '').replaceAll('()', '');
    return t['failure.network.$path'] as String;
  }
}

@freezed
class DatabaseFailure with _$DatabaseFailure, Failure {
  const DatabaseFailure._();

  const factory DatabaseFailure.unexpected(Object exception) =
      DatabaseUnexpected;
  const factory DatabaseFailure.itemNotFound() = ItemNotFound;
  const factory DatabaseFailure.itemAlreadyExists() = ItemAlreadyExists;

  factory DatabaseFailure.fromJson(Map<String, dynamic> json) =>
      _$DatabaseFailureFromJson(json);

  //test
  factory DatabaseFailure.fromException(SqliteException e) {
    if (e.extendedResultCode == 1555) {
      return const DatabaseFailure.itemAlreadyExists();
    }
    return DatabaseFailure.unexpected(e);
  }

  // TODO: improve
  factory DatabaseFailure.fromRemoteException(DriftRemoteException e) {
    if (e.remoteCause.toString().contains("SqliteException(1555)")) {
      return const DatabaseFailure.itemAlreadyExists();
    }
    return DatabaseFailure.unexpected(e);
  }

  @override
  String present(TranslationsEn t) {
    return when(
      unexpected: (_) => t.failure.unexpected,
      itemNotFound: () => t.failure.database.itemNotFound,
      itemAlreadyExists: () => t.failure.database.itemAlreadyExists,
    );
  }
}

@freezed
class ParserFailure with _$ParserFailure, Failure {
  const ParserFailure._();

  const factory ParserFailure.unexpected() = ParserUnexpected;
  const factory ParserFailure.feedNotFound() = FeedNotFound;

  factory ParserFailure.fromJson(Map<String, dynamic> json) =>
      _$ParserFailureFromJson(json);

  @override
  String present(TranslationsEn t) {
    // TODO: replace placeholder
    return 'placeholder';
  }
}
