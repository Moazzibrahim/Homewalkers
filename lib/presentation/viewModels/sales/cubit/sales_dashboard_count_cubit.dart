import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/get_sales_dashboard_count_api_service.dart';
import 'package:homewalkers_app/data/models/Data/sales_data_dashboard_count_model.dart';
import 'package:homewalkers_app/data/models/sales_dashboard_model.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/cubit/sales_dashboard_count_state.dart';

class SalesDashboardCubit extends Cubit<SalesDashboardState> {
  final SalesDashboardApiService apiService;

  SalesDashboardCubit(this.apiService) : super(SalesDashboardInitial());

  /// ===============================
  /// Normal Dashboard
  /// ===============================
  Future<void> fetchDashboard() async {
    emit(SalesDashboardLoading());

    try {
      final response = await apiService.fetchSalesDashboard();
      emit(SalesDashboardSuccess(response));
    } catch (e) {
      emit(SalesDashboardError(e.toString()));
    }
  }

  /// ===============================
  /// Dashboard COUNT (Data Center)
  /// ===============================
  Future<void> fetchDashboardDataCount() async {
    emit(SalesDashboardLoading());

    try {
      final response = await apiService.fetchSalesDataDashboardCount();
      emit(SalesDashboardCountSuccess(response));
    } catch (e) {
      emit(SalesDashboardError(e.toString()));
    }
  }

  /// ===============================
  /// Helper (Normal Dashboard)
  /// ===============================
  List<Stage> getVisibleStages(SalesStagesResponse response) {
    final allStages = response.data?.stages ?? [];

    final visibleStages =
        allStages.where((e) => (e.leadsCount ?? 0) > 0).toList();

    final noStage = allStages.firstWhere(
      (e) => (e.stageName ?? '').toLowerCase() == 'no stage',
      orElse: () => Stage(stageName: 'No Stage', leadsCount: 0),
    );

    if (!visibleStages.any(
      (e) => (e.stageName ?? '').toLowerCase() == 'no stage',
    )) {
      visibleStages.insert(0, noStage);
    }

    return visibleStages;
  }

  /// ===============================
  /// Helper (Data Center Dashboard)
  /// ===============================
  List<StageData> getVisibleStagesFromCount(
    SalesDataDashboardCountModel response,
  ) {
    final allStages = response.data?.stages ?? [];

    final visibleStages =
        allStages.where((e) => (e.leadsCount ?? 0) > 0).toList();

    final noStage = allStages.firstWhere(
      (e) => (e.stageName ?? '').toLowerCase() == 'no stage',
      orElse: () => StageData(stageName: 'No Stage', leadsCount: 0),
    );

    if (!visibleStages.any(
      (e) => (e.stageName ?? '').toLowerCase() == 'no stage',
    )) {
      visibleStages.insert(0, noStage);
    }

    return visibleStages;
  }
}