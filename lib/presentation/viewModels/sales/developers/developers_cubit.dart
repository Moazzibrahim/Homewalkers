import 'package:bloc/bloc.dart';
import 'package:homewalkers_app/data/data_sources/developers_api_service.dart';
import 'package:homewalkers_app/data/models/developers_model.dart';

part 'developers_state.dart';

class DevelopersCubit extends Cubit<DevelopersState> {
  final DeveloperApiService apiService;
  DevelopersCubit(this.apiService) : super(DevelopersInitial());

  
  Future<void> getDevelopers() async {
    emit(DeveloperLoading());
    try {
      final data = await apiService.fetchDevelopers();
      emit(DeveloperSuccess(data));
    } catch (e) {
      emit(DeveloperError(e.toString()));
    }
  }
  Future<void> getDevelopersInTrash() async {
    emit(DeveloperLoading());
    try {
      final data = await apiService.fetchDevelopersInTrash();
      emit(DeveloperSuccess(data));
    } catch (e) {
      emit(DeveloperError(e.toString()));
    }
  }
}
