import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/get_channels_api_service.dart';
import 'package:homewalkers_app/presentation/viewModels/channels/channels_state.dart';

class ChannelCubit extends Cubit<ChannelState> {
  final GetChannelsApiService channelsApiService;

  ChannelCubit(this.channelsApiService) : super(ChannelInitial());

  Future<void> fetchChannels() async {
    emit(ChannelLoading());
    try {
      final response = await channelsApiService.getChannels();
      if (response != null) {
        emit(ChannelLoaded(response));
      } else {
        emit(ChannelError('Failed to load channels'));
      }
    } catch (e) {
      emit(ChannelError('Error occurred: $e'));
    }
  }
}
