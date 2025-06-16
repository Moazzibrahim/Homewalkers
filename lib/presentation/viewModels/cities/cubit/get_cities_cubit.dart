import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/get_cities_api_service.dart';
import 'package:homewalkers_app/data/models/cities_model.dart';
import 'package:homewalkers_app/data/models/regions_model.dart';
part 'get_cities_state.dart';

class GetCitiesCubit extends Cubit<GetCitiesState> {
  final GetCitiesApiService apiService;

  GetCitiesCubit(this.apiService) : super(GetCitiesInitial());

  Future<void> fetchCities() async {
    emit(GetCitiesLoading());
    try {
      final CityResponse? response = await apiService.getCities();
      if (response != null && response.data != null) {
        emit(GetCitiesSuccess(cities: response.data!));
      } else {
        emit(GetCitiesFailure(error: 'No data received'));
      }
    } catch (e) {
      emit(GetCitiesFailure(error: e.toString()));
    }
  }
  Future<void> fetchRegions() async {
    emit(GetCitiesLoading());
    try {
      final RegionsModel? response = await apiService.getRegions();
      if (response != null) {
        emit(GetCitiesSuccess(regions: response.data));
      } else {
        emit(GetCitiesFailure(error: 'No data received'));
      }
    } catch (e) {
      emit(GetCitiesFailure(error: e.toString()));
    }
  }
}
