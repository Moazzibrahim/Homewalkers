import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/get_sales_dashboard_count_api_service.dart';
import 'package:homewalkers_app/data/models/sales_dashboard_model.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/cubit/sales_dashboard_count_state.dart';

class SalesDashboardCubit extends Cubit<SalesDashboardState> {
  final SalesDashboardApiService apiService;

  SalesDashboardCubit(this.apiService)
      : super(SalesDashboardInitial());

  Future<void> fetchDashboard() async {
    emit(SalesDashboardLoading());

    try {
      final response = await apiService.fetchSalesDashboard();
      emit(SalesDashboardSuccess(response));
    } catch (e) {
      emit(SalesDashboardError(e.toString()));
    }
  }

  /// 🔥 Helper: stages with leadsCount > 0 only
  List<Stage> getVisibleStages(SalesStagesResponse response) {
    return response.data?.stages
            ?.where((e) => (e.leadsCount ?? 0) > 0)
            .toList() ??
        [];
  }
}
