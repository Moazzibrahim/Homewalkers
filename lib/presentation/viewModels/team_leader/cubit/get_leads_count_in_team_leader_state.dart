part of 'get_leads_count_in_team_leader_cubit.dart';

abstract class GetLeadsCountInTeamLeaderState extends Equatable {
  const GetLeadsCountInTeamLeaderState();

  @override
  List<Object?> get props => [];
}

class GetLeadsCountInTeamLeaderInitial extends GetLeadsCountInTeamLeaderState {}

class GetLeadsCountInTeamLeaderLoading extends GetLeadsCountInTeamLeaderState {}

class GetLeadsCountInTeamLeaderLoaded extends GetLeadsCountInTeamLeaderState {
  final TeamLeaderResponse data;

  const GetLeadsCountInTeamLeaderLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class GetLeadsCountInTeamLeaderError extends GetLeadsCountInTeamLeaderState {
  final String message;

  const GetLeadsCountInTeamLeaderError(this.message);

  @override
  List<Object?> get props => [message];
}
