import 'package:bloc/bloc.dart';
import 'package:homewalkers_app/data/data_sources/get_all_sales_api_service.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/get_all_sales/get_all_sales_state.dart';
import 'package:shared_preferences/shared_preferences.dart';// مسار صحيح حسب مشروعك

class SalesCubit extends Cubit<SalesState> {
  final GetAllSalesApiService salesRepository;

  // لازم تمرر الـ service عند الإنشاء
  SalesCubit(this.salesRepository) : super(SalesInitial());

  Future<void> fetchSales() async {
    emit(SalesLoading());

    try {
      // هنا نفترض انك بتجيب userlogId من SharedPreferences أو أي مصدر آخر
      final prefs = await SharedPreferences.getInstance();
      final userlogId = prefs.getString('teamLeaderId') ?? '';
      final salesData = await salesRepository.fetchSalesData(userlogId);
      if (salesData != null) {
        emit(SalesLoaded(salesData));
      } else {
        emit(SalesError('Failed to fetch sales data'));
      }
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }
  Future<void> fetchAllSales() async {
    emit(SalesLoading());
    try {
      // هنا نفترض انك بتجيب userlogId من SharedPreferences أو أي مصدر آخر
      final salesData = await salesRepository.fetchAllSales();
      if (salesData != null) {
        emit(SalesLoaded(salesData));
      } else {
        emit(SalesError('Failed to fetch sales data'));
      }
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }
  Future<void> fetchAllSalesInTrash() async {
    emit(SalesLoading());
    try {
      // هنا نفترض انك بتجيب userlogId من SharedPreferences أو أي مصدر آخر
      final salesData = await salesRepository.fetchAllSalesInTrash();
      if (salesData != null) {
        emit(SalesLoaded(salesData));
      } else {
        emit(SalesError('Failed to fetch sales data'));
      }
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }
}
