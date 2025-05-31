import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/models/team_leader/get_sales_model.dart';

abstract class SalesTeamState extends Equatable {
  const SalesTeamState();

  @override
  List<Object?> get props => [];
}

class SalesTeamInitial extends SalesTeamState {}

class SalesTeamLoading extends SalesTeamState {}

class SalesTeamLoaded extends SalesTeamState {
  final SalesTeamModel salesTeam;

  const SalesTeamLoaded(this.salesTeam);

  @override
  List<Object?> get props => [salesTeam];
}

class SalesTeamError extends SalesTeamState {
  final String error;

  const SalesTeamError(this.error);

  @override
  List<Object?> get props => [error];
}
