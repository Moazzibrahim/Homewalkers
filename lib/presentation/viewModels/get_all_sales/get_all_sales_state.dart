import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/models/all_sales_model.dart';// هي الدالة fetchSalesData راح نحطها هنا

// الحالة States
abstract class SalesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final AllSalesModel salesData;

  SalesLoaded(this.salesData);

  @override
  List<Object?> get props => [salesData];
}

class SalesError extends SalesState {
  final String message;

  SalesError(this.message);

  @override
  List<Object?> get props => [message];
}