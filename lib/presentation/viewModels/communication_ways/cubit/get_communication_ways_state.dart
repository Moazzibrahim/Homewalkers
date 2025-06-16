part of 'get_communication_ways_cubit.dart';

abstract class GetCommunicationWaysState extends Equatable {
  const GetCommunicationWaysState();

  @override
  List<Object?> get props => [];
}

class GetCommunicationWaysInitial extends GetCommunicationWaysState {}

class GetCommunicationWaysLoading extends GetCommunicationWaysState {}

class GetCommunicationWaysLoaded extends GetCommunicationWaysState {
  final CommunicationWayResponse response;

  const GetCommunicationWaysLoaded(this.response);

  @override
  List<Object?> get props => [response];
}

class GetCommunicationWaysError extends GetCommunicationWaysState {
  final String message;

  const GetCommunicationWaysError(this.message);

  @override
  List<Object?> get props => [message];
}
