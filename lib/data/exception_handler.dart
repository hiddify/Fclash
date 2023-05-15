import 'dart:async';
import 'dart:io';

import 'package:clashify/domain/failures.dart';
import 'package:clashify/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:drift/remote.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

// HACK: not fully tested

mixin ExceptionHandler implements LoggerMixin {
  Future<Either<L, R>> exceptionHandler<L extends Failure, R extends Object?>(
    FutureOr<Either<L, R>> Function() computation, {
    L Function(NetworkFailure f)? onNetworkError,
    L Function(DatabaseFailure f)? onDatabaseError,
    L Function(ParserFailure f)? onParserError,
  }) async {
    try {
      return await computation();
    } catch (e) {
      return left(
        exceptionMapper(
          e,
          onNetworkError: onNetworkError,
          onDatabaseError: onDatabaseError,
          onParserError: onParserError,
        ) as L,
      );
    }
  }
}

extension StreamExceptionHandler<L extends Failure, R extends Object?>
    on Stream<R> {
  Stream<Either<L, R>> handleExceptions({
    L Function(NetworkFailure f)? onNetworkError,
    L Function(DatabaseFailure f)? onDatabaseError,
    L Function(ParserFailure f)? onParserError,
  }) {
    return map(right<L, R>).onErrorReturnWith(
      (error, stackTrace) {
        return left(exceptionMapper(error) as L);
      },
    );
  }
}

Failure exceptionMapper(
  Object e, {
  Failure Function(NetworkFailure f)? onNetworkError,
  Failure Function(DatabaseFailure f)? onDatabaseError,
  Failure Function(ParserFailure f)? onParserError,
}) {
  // loggy.warning('exception: type= [${e.runtimeType}], data= $e');
  if (e is NetworkFailure) {
    return onNetworkError?.call(e) ?? e;
  } else if (e is ParserFailure) {
    return onParserError?.call(e) ?? e;
  } else if (e is DatabaseFailure) {
    return onDatabaseError?.call(e) ?? e;
  } else if (e is DriftRemoteException) {
    // TODO: improve
    final failure = DatabaseFailure.unexpected(e);
    return onDatabaseError?.call(failure) ?? failure;
  } else if (e is DioError) {
    return onNetworkError?.call(e.toFailure()) ?? e.toFailure();
  } else if (e is SocketException) {
    final failure = NetworkFailure.unexpected(e);
    return onNetworkError?.call(failure) ?? failure;
  } else if (e is FormatException) {
    const failure = ParserFailure.unexpected();
    return onParserError?.call(failure) ?? failure;
  }
  return UnexpectedFailure(e);
}

extension DioErrorX on DioError {
  /// converts [DioError]s to appropriate [NetworkFailure]s
  // TODO: rewrite
  NetworkFailure toFailure() {
    NetworkFailure? networkFailure;
    switch (type) {
      case DioErrorType.cancel:
        networkFailure = const NetworkFailure.requestCancelled();
        break;
      case DioErrorType.connectionTimeout:
        networkFailure = const NetworkFailure.requestTimeout();
        break;
      // case DioErrorType.DEFAULT:
      //   networkFailure = const NetworkFailure.noInternetConnection();
      //   break;
      case DioErrorType.unknown:
        networkFailure = const NetworkFailure.noInternetConnection();
        break;
      case DioErrorType.receiveTimeout:
        networkFailure = const NetworkFailure.sendTimeout();
        break;
      case DioErrorType.badResponse:
        switch (response?.statusCode) {
          case 400:
            networkFailure = const NetworkFailure.unauthorisedRequest();
            break;
          case 401:
            networkFailure = const NetworkFailure.unauthorisedRequest();
            break;
          case 403:
            networkFailure = const NetworkFailure.unauthorisedRequest();
            break;
          case 404:
            networkFailure = const NetworkFailure.notFound();
            break;
          case 409:
            networkFailure = const NetworkFailure.conflict();
            break;
          case 408:
            networkFailure = const NetworkFailure.requestTimeout();
            break;
          case 500:
            networkFailure = const NetworkFailure.internalServerError();
            break;
          case 503:
            networkFailure = const NetworkFailure.serviceUnavailable();
            break;
          default:
            networkFailure = NetworkFailure.unexpected(error ?? type);
            break;
        }
        break;
      case DioErrorType.sendTimeout:
        networkFailure = const NetworkFailure.sendTimeout();
        break;
      case DioErrorType.badCertificate:
        // TODO: Handle this case.
        networkFailure = const NetworkFailure.noInternetConnection();
        break;
      case DioErrorType.connectionError:
        // TODO: Handle this case.
        networkFailure = const NetworkFailure.noInternetConnection();
        break;
    }
    return networkFailure;
  }
}
