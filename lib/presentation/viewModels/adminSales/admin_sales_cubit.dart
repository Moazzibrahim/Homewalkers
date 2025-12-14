import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/fetch_admin_sales_api_service.dart';
import 'package:homewalkers_app/data/models/admin_sales_model.dart';

import 'admin_sales_state.dart';

class AdminSalesCubit extends Cubit<AdminSalesState> {
  final FetchAdminSalesApiService service;

  AdminSalesCubit(this.service) : super(AdminSalesInitial());

  Future<void> fetchSalesLeadsCount() async {
    emit(AdminSalesLoading());

    try {
      final AdminSalesModel response =
          await service.getSalesLeadsCount();

      emit(AdminSalesLoaded(response));
    } catch (e) {
      emit(
        AdminSalesError(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
