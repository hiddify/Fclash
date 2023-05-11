import 'package:freezed_annotation/freezed_annotation.dart';

part 'mutation_state.freezed.dart';

@freezed
class MutationState with _$MutationState {
  const MutationState._();

  const factory MutationState.initial() = _Initial;
  const factory MutationState.inProgress() = _InProgress;
  const factory MutationState.failure(Object failure) = _Failure;
  const factory MutationState.success() = _Success;

  bool get isInProgress => this is _InProgress;
}
