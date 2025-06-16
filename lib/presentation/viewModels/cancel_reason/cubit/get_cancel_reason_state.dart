part of 'get_cancel_reason_cubit.dart';

abstract class GetCancelReasonState extends Equatable {
  const GetCancelReasonState();

  @override
  List<Object?> get props => [];
}

class GetCancelReasonInitial extends GetCancelReasonState {}

class GetCancelReasonLoading extends GetCancelReasonState {}

class GetCancelReasonLoaded extends GetCancelReasonState {
  final CancelReasonResponse response;

  const GetCancelReasonLoaded({required this.response});

  @override
  List<Object?> get props => [response];
}

class GetCancelReasonError extends GetCancelReasonState {
  final String message;

  const GetCancelReasonError({required this.message});

  @override
  List<Object?> get props => [message];
}
