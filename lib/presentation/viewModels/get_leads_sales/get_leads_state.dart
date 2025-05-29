part of 'get_leads_cubit.dart';

@immutable
sealed class GetLeadsState {}

final class GetLeadsInitial extends GetLeadsState {}

final class GetLeadsLoading extends GetLeadsState {}

final class GetLeadsSuccess extends GetLeadsState {
  final LeadResponse assignedModel;

  GetLeadsSuccess(this.assignedModel);
}

final class GetLeadsError extends GetLeadsState {
  final String message;

  GetLeadsError(this.message);
}
