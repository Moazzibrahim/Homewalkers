part of 'get_leads_team_leader_cubit.dart';

sealed class GetLeadsTeamLeaderState extends Equatable {
  const GetLeadsTeamLeaderState();

  @override
  List<Object> get props => [];
}

final class GetLeadsTeamLeaderInitial extends GetLeadsTeamLeaderState {}

final class GetLeadsTeamLeaderLoading extends GetLeadsTeamLeaderState {}

final class GetLeadsTeamLeaderSuccess extends GetLeadsTeamLeaderState {
  final LeadResponse leadsData;

  const GetLeadsTeamLeaderSuccess(this.leadsData);

  @override
  List<Object> get props => [leadsData];
}

final class GetLeadsTeamLeaderError extends GetLeadsTeamLeaderState {
  final String message;

  const GetLeadsTeamLeaderError(this.message);

  @override
  List<Object> get props => [message];
}
