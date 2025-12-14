import 'package:homewalkers_app/data/models/admin_sales_model.dart';

abstract class AdminSalesState {}

class AdminSalesInitial extends AdminSalesState {}

class AdminSalesLoading extends AdminSalesState {}

class AdminSalesLoaded extends AdminSalesState {
  final AdminSalesModel data;

  AdminSalesLoaded(this.data);
}

class AdminSalesError extends AdminSalesState {
  final String message;

  AdminSalesError(this.message);
}
