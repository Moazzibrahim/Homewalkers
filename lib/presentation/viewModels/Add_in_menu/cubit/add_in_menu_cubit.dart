// ignore_for_file: non_constant_identifier_names

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/marketer/add_menu_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/delete_menu_api_service.dart';
import 'package:homewalkers_app/data/data_sources/marketer/update_menu_api_service.dart';
part 'add_in_menu_state.dart';

class AddInMenuCubit extends Cubit<AddInMenuState> {
  final AddMenuApiService _apiService;
  final UpdateMenuApiService _updateApiService;
  final DeleteMenuApiService _deleteApiService;

  AddInMenuCubit(
    this._apiService,
    this._updateApiService,
    this._deleteApiService,
  ) : super(AddInMenuInitial());

  Future<void> addCommunicationWay(String name) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.addCommunicationWay(name);
      emit(AddInMenuSuccess(message: 'Added successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to add: $e'));
    }
  }

  Future<void> addStage(String name, String stageType, String comment) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.addStage(name, stageType, comment);
      emit(AddInMenuSuccess(message: 'Added successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to add: $e'));
    }
  }

  Future<void> addStagetype(String name, String comment) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.addStageType(name, comment);
      emit(AddInMenuSuccess(message: 'Added successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to add: $e'));
    }
  }

  Future<void> addSales(
    String name,
    List<String> city,
    String teamleaderId,
    String managerId,
    bool isactive,
    String notes,
  ) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.addSales(
        name,
        city,
        teamleaderId,
        managerId,
        isactive,
        notes,
      );
      emit(AddInMenuSuccess(message: 'Added successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to add: $e'));
    }
  }

  Future<void> addUsers(
    String name,
    String email,
    String phone,
    String password,
    String confirmpassword,
    String role,
  ) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.addUsers(
        name,
        email,
        phone,
        password,
        confirmpassword,
        role,
      );
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

  Future<void> addProject(
    String name,
    String developerId,
    String cityId,
    String area,
  ) async {
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

  Future<void> addCity(String city) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.addCity(city);
      emit(AddInMenuSuccess(message: 'City added successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to add cancel reason: $e'));
    }
  }

  Future<void> addCampaign(
    String name,
    String date,
    String cost,
    bool isActive,
    String addBy,
    String updatedBy,
  ) async {
    emit(AddInMenuLoading());
    try {
      await _apiService.postCampaign(
        name,
        date,
        cost,
        isActive,
        addBy,
        updatedBy,
      );
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
  // ----------- Update Methods -----------

  Future<void> updateCommunicationWay(String name, String id) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateCommunicationWay(name, id);
      emit(AddInMenuSuccess(message: 'Communication way updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update: $e'));
    }
  }

  Future<void> updateCommunicationWayStatus(String id, bool active) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateCommunicationWayStatus(id, active);
      emit(AddInMenuSuccess(message: 'Status updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update status: $e'));
    }
  }

  Future<void> updateSales(String name, String salesIdi) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateSales(name, salesIdi);
      emit(AddInMenuSuccess(message: 'sales updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update: $e'));
    }
  }

  Future<void> updateSalesStatus(bool isactive, String salesIdi) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateSalesStatus(isactive, salesIdi);
      emit(AddInMenuSuccess(message: 'sales updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update: $e'));
    }
  }

  Future<void> updateUser(
    String name,
    String idi,
    String email,
    String phone,
    String role,
    bool opencomments,
    bool CloseDoneDealcomments,
  ) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateUser(
        name,
        idi,
        email,
        phone,
        role,
        opencomments,
        CloseDoneDealcomments,
      );
      emit(AddInMenuSuccess(message: 'user updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update: $e'));
    }
  }

  Future<void> updateUserStatus(String idi, bool isactive) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateUserstatus(isactive, idi);
      emit(AddInMenuSuccess(message: 'user updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update: $e'));
    }
  }

  Future<void> updateUserPassword(
    String idi,
    String currentPassword,
    String password,
    String confirmpassword,
  ) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateUserPassword(
        idi,
        currentPassword,
        password,
        confirmpassword,
      );
      emit(AddInMenuSuccess(message: 'user password updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update: $e'));
    }
  }

  Future<void> updateStage(
    String name,
    String stageId,
    String stageType,
    String comment,
  ) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateStage(name, stageId, stageType, comment);
      emit(AddInMenuSuccess(message: 'stage updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update: $e'));
    }
  }

  // ✅ تمت الإضافة
  Future<void> updateStageStatus(String id, bool active) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateStageStatus(id, active);
      emit(AddInMenuSuccess(message: 'Status updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update status: $e'));
    }
  }

  Future<void> updateStagetype(
    String name,
    String stageId,
    String comment,
  ) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateStageType(name, stageId, comment);
      emit(AddInMenuSuccess(message: 'stage type updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update: $e'));
    }
  }

  Future<void> updateStageTypeStatus(String id, bool active) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateStageTypeStatus(id, active);
      emit(AddInMenuSuccess(message: 'Status updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update status: $e'));
    }
  }

  Future<void> updateDeveloper(String name, String id) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateDeveloper(name, id);
      emit(AddInMenuSuccess(message: 'Developer updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update developer: $e'));
    }
  }

  // ✅ تمت الإضافة
  Future<void> updateDeveloperStatus(String id, bool active) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateDeveloperStatus(id, active);
      emit(AddInMenuSuccess(message: 'Status updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update status: $e'));
    }
  }

  Future<void> updateProject(
    String name,
    String developerId,
    String cityId,
    String area,
    String id,
  ) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateDProject(
        name,
        developerId,
        cityId,
        area,
        id,
      );
      emit(AddInMenuSuccess(message: 'Project updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update project: $e'));
    }
  }

  Future<void> updateDProjectStatus(String id, bool active) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateDProjectStatus(id, active);
      emit(AddInMenuSuccess(message: 'Status updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update status: $e'));
    }
  }

  Future<void> updateChannel(String name, String code, String id) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateChannel(name, code, id);
      emit(AddInMenuSuccess(message: 'Channel updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update channel: $e'));
    }
  }

  // ✅ تمت الإضافة
  Future<void> updateChannelStatus(String id, bool active) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateChannelStatus(id, active);
      emit(AddInMenuSuccess(message: 'Status updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update status: $e'));
    }
  }

  Future<void> updateCancelReason(String reason, String id) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateCancelReasons(reason, id);
      emit(AddInMenuSuccess(message: 'Cancel reason updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update cancel reason: $e'));
    }
  }

  // ✅ تمت الإضافة
  Future<void> updateCancelReasonsStatus(String id, bool active) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateCancelReasonsStatus(id, active);
      emit(AddInMenuSuccess(message: 'Status updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update status: $e'));
    }
  }

  Future<void> updateCampaign(
    String name,
    String date,
    String cost,
    bool isActive,
    String addBy,
    String updatedBy,
    String id,
  ) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateCampaign(
        name,
        date,
        cost,
        isActive,
        addBy,
        updatedBy,
        id,
      );
      emit(AddInMenuSuccess(message: 'Campaign updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update campaign: $e'));
    }
  }

  Future<void> updateCampaignStatus(String id, bool active) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateCampaignStatus(id, active);
      emit(AddInMenuSuccess(message: 'Status updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update status: $e'));
    }
  }

  Future<void> updateRegion(String name, String id) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateRegion(name, id);
      emit(AddInMenuSuccess(message: 'Region updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update region: $e'));
    }
  }

  // ✅ تمت الإضافة
  Future<void> updateRegionStatus(String id, bool active, String region) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateRegionStatus(id, active,region);
      emit(AddInMenuSuccess(message: 'Status updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update status: $e'));
    }
  }

  Future<void> updateArea(String area, String regionId, String id) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateArea(area, regionId, id);
      emit(AddInMenuSuccess(message: 'Area updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update area: $e'));
    }
  }

  // ✅ تمت الإضافة
  Future<void> updateAreaStatus(String id, bool active) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateAreaStatus(id, active);
      emit(AddInMenuSuccess(message: 'Status updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update status: $e'));
    }
  }

  Future<void> updateCity(String name, String salesIdi) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateCity(name, salesIdi);
      emit(AddInMenuSuccess(message: 'city updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update: $e'));
    }
  }
  Future<void> updateCityStatus(String cityId,bool active) async {
    emit(AddInMenuLoading());
    try {
      await _updateApiService.updateCityStatus(cityId,active);
      emit(AddInMenuSuccess(message: 'city updated successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to update: $e'));
    }
  }
  // ----------- Delete Methods -----------

  Future<void> deleteCommunicationWay(String id) async {
    emit(AddInMenuLoading());
    try {
      await _deleteApiService.deleteCommunicationWay(id);
      emit(AddInMenuSuccess(message: 'Communication way deleted successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to delete communication way: $e'));
    }
  }

  Future<void> deleteDeveloper(String id) async {
    emit(AddInMenuLoading());
    try {
      await _deleteApiService.deleteDeveloper(id);
      emit(AddInMenuSuccess(message: 'Developer deleted successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to delete developer: $e'));
    }
  }

  Future<void> deleteProject(String id) async {
    emit(AddInMenuLoading());
    try {
      await _deleteApiService.deleteProject(id);
      emit(AddInMenuSuccess(message: 'Project deleted successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to delete project: $e'));
    }
  }

  Future<void> deleteChannel(String id) async {
    emit(AddInMenuLoading());
    try {
      await _deleteApiService.deleteChannel(id);
      emit(AddInMenuSuccess(message: 'Channel deleted successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to delete channel: $e'));
    }
  }

  Future<void> deleteCancelReason(String id) async {
    emit(AddInMenuLoading());
    try {
      await _deleteApiService.deleteCancelReason(id);
      emit(AddInMenuSuccess(message: 'Cancel reason deleted successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to delete cancel reason: $e'));
    }
  }

  Future<void> deleteCampaign(String id) async {
    emit(AddInMenuLoading());
    try {
      await _deleteApiService.deleteCampaign(id);
      emit(AddInMenuSuccess(message: 'Campaign deleted successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to delete campaign: $e'));
    }
  }

  Future<void> deleteRegion(String id) async {
    emit(AddInMenuLoading());
    try {
      await _deleteApiService.deleteRegion(id);
      emit(AddInMenuSuccess(message: 'Region deleted successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to delete region: $e'));
    }
  }

  Future<void> deleteArea(String id) async {
    emit(AddInMenuLoading());
    try {
      await _deleteApiService.deleteArea(id);
      emit(AddInMenuSuccess(message: 'Area deleted successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to delete area: $e'));
    }
  }

  Future<void> deleteSales(String id) async {
    emit(AddInMenuLoading());
    try {
      await _deleteApiService.deleteSales(id);
      emit(AddInMenuSuccess(message: 'sales deleted successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to delete sales: $e'));
    }
  }

  Future<void> deleteStage(String id) async {
    emit(AddInMenuLoading());
    try {
      await _deleteApiService.deleteStage(id);
      emit(AddInMenuSuccess(message: 'stage deleted successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to delete stage: $e'));
    }
  }

  Future<void> deleteStagetype(String id) async {
    emit(AddInMenuLoading());
    try {
      await _deleteApiService.deleteStagetype(id);
      emit(AddInMenuSuccess(message: 'stage type deleted successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to delete stage type: $e'));
    }
  }

  Future<void> deleteCity(String id) async {
    emit(AddInMenuLoading());
    try {
      await _deleteApiService.deleteCity(id);
      emit(AddInMenuSuccess(message: 'city deleted successfully'));
    } catch (e) {
      emit(AddInMenuError(message: 'Failed to delete city: $e'));
    }
  }
}
