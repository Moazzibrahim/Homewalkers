import 'package:homewalkers_app/data/models/sales_dashboard_model.dart';

abstract class SalesDashboardState {}

class SalesDashboardInitial extends SalesDashboardState {}

class SalesDashboardLoading extends SalesDashboardState {}

class SalesDashboardSuccess extends SalesDashboardState {
  final SalesStagesResponse response;

  SalesDashboardSuccess(this.response);
}

class SalesDashboardError extends SalesDashboardState {
  final String message;

  SalesDashboardError(this.message);
}
