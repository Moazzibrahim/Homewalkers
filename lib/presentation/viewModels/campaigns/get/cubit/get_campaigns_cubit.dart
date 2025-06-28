import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/campaign_api_service.dart';
import 'package:homewalkers_app/data/models/campaign_models.dart';
part 'get_campaigns_state.dart';

class GetCampaignsCubit extends Cubit<GetCampaignsState> {
  final CampaignApiService _campaignApiService;

  GetCampaignsCubit(this._campaignApiService) : super(GetCampaignsInitial());

  Future<void> fetchCampaigns() async {
    emit(GetCampaignsLoading());
    try {
      final response = await _campaignApiService.getCampaigns();
      if (response != null && response.data != null) {
        emit(GetCampaignsSuccess(response));
      } else {
        emit(GetCampaignsFailure("No campaigns found"));
      }
    } catch (e) {
      emit(GetCampaignsFailure("Error: $e"));
    }
  }
  Future<void> fetchCampaignsInTrash() async {
    emit(GetCampaignsLoading());
    try {
      final response = await _campaignApiService.getCampaignsInTrash();
      if (response != null && response.data != null) {
        emit(GetCampaignsSuccess(response));
      } else {
        emit(GetCampaignsFailure("No campaigns found"));
      }
    } catch (e) {
      emit(GetCampaignsFailure("Error: $e"));
    }
  }
}
