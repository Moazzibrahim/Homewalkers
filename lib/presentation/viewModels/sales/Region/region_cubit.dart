import 'package:bloc/bloc.dart';
import 'package:homewalkers_app/data/data_sources/region_api_service.dart';
import 'region_state.dart';

class RegionCubit extends Cubit<RegionState> {
  final RegionApiService regionApiService;

  RegionCubit(this.regionApiService) : super(RegionInitial());

  Future<void> fetchRegions() async {
    emit(RegionLoading());

    try {
      final regions = await regionApiService.fetchRegions();
      emit(RegionLoaded(regions));
    } catch (e) {
      emit(RegionError(e.toString()));
    }
  }
}
