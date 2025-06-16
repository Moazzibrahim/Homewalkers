import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/models/communication_ways_model.dart';
import 'package:homewalkers_app/data/data_sources/communication_way_api_service.dart';

part 'get_communication_ways_state.dart';

class GetCommunicationWaysCubit extends Cubit<GetCommunicationWaysState> {
  final CommunicationWayApiService apiService;

  GetCommunicationWaysCubit(this.apiService)
      : super(GetCommunicationWaysInitial());

  Future<void> fetchCommunicationWays() async {
    emit(GetCommunicationWaysLoading());
    try {
      final result = await apiService.fetchCommunicationWays();
      if (result != null) {
        emit(GetCommunicationWaysLoaded(result));
      } else {
        emit(const GetCommunicationWaysError('No data received.'));
      }
    } catch (e) {
      emit(GetCommunicationWaysError(e.toString()));
    }
  }
}
