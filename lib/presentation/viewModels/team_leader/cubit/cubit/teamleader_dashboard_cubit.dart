import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_dashboard_leads_count.dart';
import 'teamleader_dashboard_state.dart';

class TeamleaderDashboardCubit extends Cubit<TeamleaderDashboardState> {
  final TeamleaderDashboardApiService apiService;

  TeamleaderDashboardCubit(this.apiService)
    : super(TeamleaderDashboardInitial());

  Future<void> fetchDashboard() async {
    emit(TeamleaderDashboardLoading());

    try {
      final response = await apiService.fetchDashboard();
      emit(TeamleaderDashboardSuccess(response));
    } catch (e) {
      emit(
        TeamleaderDashboardError(
          "could not fetch data. Please try again later. contact support if issue persists.",
        ),
      );
    }
  }
}
