import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/models/areas_model.dart';
import 'package:homewalkers_app/data/data_sources/area_api_service.dart';

part 'get_area_state.dart';

class GetAreaCubit extends Cubit<GetAreaState> {
  final AreaApiService _areaApiService;

  GetAreaCubit(this._areaApiService) : super(GetAreaInitial());

  Future<void> fetchAreas() async {
    emit(GetAreaLoading());

    final result = await _areaApiService.getAreas();

    if (result != null && result.data != null) {
      emit(GetAreaLoaded(result.data!));
    } else {
      emit(GetAreaError('Failed to load areas'));
    }
  }
  Future<void> fetchAreasInTrash() async {
    emit(GetAreaLoading());

    final result = await _areaApiService.getAreasInTrash();
    if (result != null && result.data != null) {
      emit(GetAreaLoaded(result.data!));
    } else {
      emit(GetAreaError('Failed to load areas'));
    }
  }
}
