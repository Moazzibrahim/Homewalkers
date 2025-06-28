import 'package:bloc/bloc.dart';
import 'package:homewalkers_app/data/data_sources/stages_api_service.dart';
import 'package:meta/meta.dart';
import 'package:homewalkers_app/data/models/stages_models.dart';

part 'stages_state.dart';

class StagesCubit extends Cubit<StagesState> {
  final StagesApiService apiService;

  StagesCubit(this.apiService) : super(StagesInitial());

  Future<void> fetchStages() async {
  emit(StagesLoading());

  final result = await apiService.fetchStages();

  if (result != null) {
    emit(StagesLoaded(result.data!)); // result.data هي List<StageModel>
  } else {
    emit(StagesError("فشل في جلب البيانات"));
  }
}
Future<void> fetchStagesInTrash() async {
  emit(StagesLoading());

  final result = await apiService.fetchStagesInTrash();

  if (result != null) {
    emit(StagesLoaded(result.data!)); // result.data هي List<StageModel>
  } else {
    emit(StagesError("فشل في جلب البيانات"));
  }
}
}
