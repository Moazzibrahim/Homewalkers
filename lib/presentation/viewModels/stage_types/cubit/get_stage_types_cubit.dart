import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/get_stage_types_api_service.dart';
import 'package:homewalkers_app/data/models/stage_type_model.dart'; // Make sure this is the correct path
part 'get_stage_types_state.dart';

class GetStageTypesCubit extends Cubit<GetStageTypesState> {
  final StageTypeApiService apiService;

  GetStageTypesCubit(this.apiService) : super(GetStageTypesInitial());

  Future<void> fetchStageTypes() async {
    emit(GetStageTypesLoading());

    final response = await apiService.fetchStageTypes();

    if (response != null && response.data != null) {
      emit(GetStageTypesSuccess(response));
    } else {
      emit(GetStageTypesFailure("Failed to fetch stage types"));
    }
  }
}
