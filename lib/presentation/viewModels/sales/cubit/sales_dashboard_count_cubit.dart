import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/get_sales_dashboard_count_api_service.dart';
import 'package:homewalkers_app/data/models/sales_dashboard_model.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/cubit/sales_dashboard_count_state.dart';

class SalesDashboardCubit extends Cubit<SalesDashboardState> {
  final SalesDashboardApiService apiService;

  SalesDashboardCubit(this.apiService) : super(SalesDashboardInitial());

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
  /// 🔥 Helper: stages with leadsCount > 0
  /// ➕ Always include "No Stage" even if count = 0
  List<Stage> getVisibleStages(SalesStagesResponse response) {
    final allStages = response.data?.stages ?? [];

    // stages اللي ليها count
    final visibleStages =
        allStages.where((e) => (e.leadsCount ?? 0) > 0).toList();

    // check لو No Stage موجودة في الداتا الأصلية
    final noStage = allStages.firstWhere(
      (e) => (e.stageName ?? '').toLowerCase() == 'no stage',
      orElse: () => Stage(stageName: 'No Stage', leadsCount: 0),
    );

    // لو No Stage مش موجودة في visibleStages → نضيفها
    final alreadyAdded = visibleStages.any(
      (e) => (e.stageName ?? '').toLowerCase() == 'no stage',
    );

    if (!alreadyAdded) {
      visibleStages.insert(0, noStage);
    }

    return visibleStages;
  }
}
