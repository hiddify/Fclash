import 'package:clashify/core/prefs/locale/locale.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';
part 'failures.g.dart';

mixin Failure {
  String present(TranslationsEn t);
}

@freezed
class NetworkFailure with _$NetworkFailure, Failure {
  const NetworkFailure._();

  const factory NetworkFailure.unexpected(Object error) = NetworkUnexpected;
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
    return when(
      unexpected: (_) => t.failure.unexpected,
      noInternetConnection: () => t.failure.network.noInternetConnection,
      requestCancelled: () => t.failure.network.requestCancelled,
      notFound: () => t.failure.network.notFound,
      unauthorisedRequest: () => t.failure.network.unauthorisedRequest,
      badRequest: () => t.failure.network.badRequest,
      sendTimeout: () => t.failure.network.sendTimeout,
      requestTimeout: () => t.failure.network.requestTimeout,
      conflict: () => t.failure.network.conflict,
      internalServerError: () => t.failure.network.internalServerError,
      serviceUnavailable: () => t.failure.network.serviceUnavailable,
    );
  }
}

@freezed
class DatabaseFailure with _$DatabaseFailure, Failure {
  const DatabaseFailure._();

  const factory DatabaseFailure.unexpected(Object error) = DatabaseUnexpected;
  const factory DatabaseFailure.itemNotFound() = ItemNotFound;
  const factory DatabaseFailure.itemAlreadyExists() = ItemAlreadyExists;

  factory DatabaseFailure.fromJson(Map<String, dynamic> json) =>
      _$DatabaseFailureFromJson(json);

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

  factory ParserFailure.fromJson(Map<String, dynamic> json) =>
      _$ParserFailureFromJson(json);

  @override
  String present(TranslationsEn t) {
    return t.failure.unexpected;
  }
}

@freezed
class UnexpectedFailure with _$UnexpectedFailure, Failure {
  const UnexpectedFailure._();

  const factory UnexpectedFailure(Object error) = OtherUnexpectedFailure;

  factory UnexpectedFailure.fromJson(Map<String, dynamic> json) =>
      _$UnexpectedFailureFromJson(json);

  @override
  String present(TranslationsEn t) {
    return t.failure.unexpected;
  }
}
