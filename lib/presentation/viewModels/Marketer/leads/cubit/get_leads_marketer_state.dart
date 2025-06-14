part of 'get_leads_marketer_cubit.dart';

sealed class GetLeadsMarketerState extends Equatable {
  const GetLeadsMarketerState();

  @override
  List<Object> get props => [];
}

final class GetLeadsMarketerInitial extends GetLeadsMarketerState {}

final class GetLeadsMarketerLoading extends GetLeadsMarketerState {}

final class GetLeadsMarketerSuccess extends GetLeadsMarketerState {
  final LeadResponse leadsResponse;
  const GetLeadsMarketerSuccess(this.leadsResponse);    
}

final class GetLeadsMarketerFailure extends GetLeadsMarketerState {
  final String errorMessage;
  const GetLeadsMarketerFailure(this.errorMessage);
}
