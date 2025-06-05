part of 'get_manager_leads_cubit.dart';

sealed class GetManagerLeadsState extends Equatable {
  const GetManagerLeadsState();

  @override
  List<Object> get props => [];
}

final class GetManagerLeadsInitial extends GetManagerLeadsState {}

final class GetManagerLeadsLoading extends GetManagerLeadsState {}

final class GetManagerLeadsSuccess extends GetManagerLeadsState {
  final LeadResponse leads;

  const GetManagerLeadsSuccess(this.leads);

  @override
  List<Object> get props => [leads];
}

final class GetManagerLeadsFailure extends GetManagerLeadsState {
  final String message;

  const GetManagerLeadsFailure(this.message);

  @override
  List<Object> get props => [message];
}


