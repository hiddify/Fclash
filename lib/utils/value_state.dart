import 'package:clashify/domain/failures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'value_state.freezed.dart';

@freezed
class ValueState<T> with _$ValueState<T> {
  const ValueState._();

  const factory ValueState.initial() = _Initial<T>;
  const factory ValueState.loading() = _Loading<T>;
  const factory ValueState.failure(Failure failure) = _Failure<T>;
  const factory ValueState.data(T data) = _Data<T>;

  factory ValueState.fromAsyncValue(AsyncValue<T> value) {
    return value.when(
      data: (data) => _Data(data),
      error: (error, stackTrace) {
        if (error is Failure) {
          return _Failure(error);
        }
        return _Failure(UnexpectedFailure(error));
      },
      loading: () => const _Loading(),
    );
  }

  T? get data => whenOrNull(data: (data) => data);

  bool get isLoading => maybeWhen(
        loading: () => true,
        orElse: () => false,
      );

  bool get hasFailure => maybeWhen(
        failure: (_) => true,
        orElse: () => false,
      );

  bool get hasData => maybeWhen(
        data: (_) => true,
        orElse: () => false,
      );

  ValueState<R> whenData<R>(R Function(T value) d) => map(
        initial: (_) => const _Initial(),
        loading: (_) => const _Loading(),
        failure: (v) => _Failure(v.failure),
        data: (v) => ValueState.data(d(v.data)),
      );

  AsyncValue<T> toAsyncValue() {
    return when(
      initial: () => const AsyncValue.loading(),
      loading: () => const AsyncValue.loading(),
      failure: (failure) => AsyncValue.error(failure, StackTrace.current),
      data: (data) => AsyncValue.data(data),
    );
  }
}
