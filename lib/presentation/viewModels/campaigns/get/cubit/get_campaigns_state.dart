part of 'get_campaigns_cubit.dart';

abstract class GetCampaignsState extends Equatable {
  const GetCampaignsState();

  @override
  List<Object?> get props => [];
}

class GetCampaignsInitial extends GetCampaignsState {}

class GetCampaignsLoading extends GetCampaignsState {}

class GetCampaignsSuccess extends GetCampaignsState {
  final CampaignResponse campaigns;

  const GetCampaignsSuccess(this.campaigns);

  @override
  List<Object?> get props => [campaigns];
}

class GetCampaignsFailure extends GetCampaignsState {
  final String message;

  const GetCampaignsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
