import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/models/Data/teamleader_data_dashboard_model.dart';
import 'package:homewalkers_app/data/models/team_leader/dashboard_count.dart';

abstract class TeamleaderDashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TeamleaderDashboardInitial extends TeamleaderDashboardState {}

class TeamleaderDashboardLoading extends TeamleaderDashboardState {}

class TeamleaderDashboardSuccess extends TeamleaderDashboardState {
  final TeamleaderDashboardResponse response;

  TeamleaderDashboardSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

/// New state for TeamleaderDataDashboardModel
class TeamleaderDashboardDataSuccess extends TeamleaderDashboardState {
  final TeamleaderDataDashboardModel data;

  TeamleaderDashboardDataSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class TeamleaderDashboardError extends TeamleaderDashboardState {
  final String message;

  TeamleaderDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
