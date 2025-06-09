import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_leads_count.dart';
import 'package:homewalkers_app/data/models/team_leader/get_leads_count_model.dart';

part 'get_leads_count_in_team_leader_state.dart';

class GetLeadsCountInTeamLeaderCubit extends Cubit<GetLeadsCountInTeamLeaderState> {
  final GetLeadsCountApiService apiService;
  TeamLeaderResponse? _fullData; // store full data for filtering

  GetLeadsCountInTeamLeaderCubit(this.apiService)
      : super(GetLeadsCountInTeamLeaderInitial());

  Future<void> fetchLeadsCount() async {
    emit(GetLeadsCountInTeamLeaderLoading());

    try {
      final result = await apiService.fetchSalesData();

      if (result != null) {
        _fullData = result; // keep full data
        emit(GetLeadsCountInTeamLeaderLoaded(result));
      } else {
        emit(const GetLeadsCountInTeamLeaderError('فشل تحميل البيانات'));
      }
    } catch (e) {
      emit(GetLeadsCountInTeamLeaderError(e.toString()));
    }
  }

  /// Filters sales by name and emits a loaded state with filtered data.
  void filterSalesByName(String query) {
    if (_fullData == null) return;

    if (query.isEmpty) {
      // if query is empty, emit full data again
      emit(GetLeadsCountInTeamLeaderLoaded(_fullData!));
    } else {
      final filteredSales = _fullData!.data?.where((sales) {
        final salesName = sales.salesName?.toLowerCase() ?? '';
        return salesName.contains(query.toLowerCase());
      }).toList();

      // create new TeamLeaderResponse with filtered sales data, keep other fields same
      final filteredResult = TeamLeaderResponse(
        success: _fullData!.success,
        teamLeader: _fullData!.teamLeader,
        totalSales: _fullData!.totalSales,
        totalReviewerLeads: _fullData!.totalReviewerLeads,
        data: filteredSales ?? [],
      );

      emit(GetLeadsCountInTeamLeaderLoaded(filteredResult));
    }
  }
}

