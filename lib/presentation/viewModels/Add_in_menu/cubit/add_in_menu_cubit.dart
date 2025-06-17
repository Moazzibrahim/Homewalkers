import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/marketer/add_menu_api_service.dart';

part 'add_in_menu_state.dart';

class AddInMenuCubit extends Cubit<AddInMenuState> {
  final AddMenuApiService _apiService;

  AddInMenuCubit(this._apiService) : super(AddInMenuInitial());

  Future<void> addCommunicationWay(String name) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.addCommunicationWay(name);
      emit(AddInMenuSuccess(message: 'Added successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to add: $e'));
    }
  }
  Future<void> addDeveloper(String name) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.addDeveloper(name);
      emit(AddInMenuSuccess(message: 'Developer added successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to add developer: $e'));
    }
  }
  Future<void> addProject(String name, String developerId, String cityId, String area) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.addDProject(name, developerId, cityId, area);
      emit(AddInMenuSuccess(message: 'Project added successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to add project: $e'));
    }
  }
  Future<void> addChannel(String name, String code) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.addChannel(name, code);
      emit(AddInMenuSuccess(message: 'Channel added successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to add channel: $e'));
    }
  }
  Future<void> addCancelReason(String reason) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.addCancelReasons(reason);
      emit(AddInMenuSuccess(message: 'Cancel reason added successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to add cancel reason: $e'));
    }
  }
  Future<void> addCampaign(String name, String date, String cost, bool isActive, String addBy, String updatedBy) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.postCampaign(name, date, cost, isActive, addBy, updatedBy);
      emit(AddInMenuSuccess(message: 'Campaign added successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to add campaign: $e'));
    }
  }
  Future<void> addRegion(String name) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.addRegion(name);
      emit(AddInMenuSuccess(message: 'Region added successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to add region: $e'));
    }
  }
  Future<void> addArea(String area, String regionId) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.addArea(area, regionId);
      emit(AddInMenuSuccess(message: 'Area added successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to add area: $e'));
    }
  }
}
