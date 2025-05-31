import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/team_leader/get_sales_by_team_leader_api_service.dart';
import 'package:homewalkers_app/data/models/team_leader/get_sales_model.dart';
import 'package:homewalkers_app/presentation/viewModels/team_leader/cubit/get_sales_team_leader_state.dart';
class SalesTeamCubit extends Cubit<SalesTeamState> {
  final GetSalesTeamLeaderApiService apiService;

  SalesTeamModel? _fullSalesModel;

  SalesTeamCubit(this.apiService) : super(SalesTeamInitial());

  Future<void> fetchSalesTeam() async {
    emit(SalesTeamLoading());

    final result = await apiService.getSalesTeamLeader();

    if (result != null) {
      _fullSalesModel = result;
      emit(SalesTeamLoaded(_fullSalesModel!));
    } else {
      emit(const SalesTeamError("Failed to fetch sales team data"));
    }
  }

  void filterSalesByName(String name) {
    if (_fullSalesModel == null) return; // لو ما جالك بيانات بعد

    if (name.isEmpty) {
      emit(SalesTeamLoaded(_fullSalesModel!));
    } else {
      final filteredList = _fullSalesModel!.data
              ?.where((sale) =>
                  sale.name != null &&
                  sale.name!.toLowerCase().contains(name.toLowerCase()))
              .toList() ??
          [];
      // نبني نموذج جديد مع البيانات المفلترة بس، وباقي الحقول زي ما هي
      final filteredModel = SalesTeamModel(
        success: _fullSalesModel!.success,
        count: filteredList.length,
        data: filteredList,
      );

      emit(SalesTeamLoaded(filteredModel));
    }
  }
}
