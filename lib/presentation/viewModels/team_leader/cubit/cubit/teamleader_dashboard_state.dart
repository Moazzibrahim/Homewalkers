import 'package:homewalkers_app/data/models/team_leader/dashboard_count.dart';


abstract class TeamleaderDashboardState {}

class TeamleaderDashboardInitial extends TeamleaderDashboardState {}

class TeamleaderDashboardLoading extends TeamleaderDashboardState {}

class TeamleaderDashboardSuccess extends TeamleaderDashboardState {
  final TeamleaderDashboardResponse response;

  TeamleaderDashboardSuccess(this.response);
}

class TeamleaderDashboardError extends TeamleaderDashboardState {
  final String message;

  TeamleaderDashboardError(this.message);
}
