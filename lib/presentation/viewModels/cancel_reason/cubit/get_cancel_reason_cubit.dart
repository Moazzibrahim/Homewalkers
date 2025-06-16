import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/models/cancel_reason_model.dart';
import 'package:homewalkers_app/data/data_sources/cancel_reason_api_service.dart';
part 'get_cancel_reason_state.dart';

class GetCancelReasonCubit extends Cubit<GetCancelReasonState> {
  final CancelReasonApiService apiService;

  GetCancelReasonCubit(this.apiService) : super(GetCancelReasonInitial());

  Future<void> fetchCancelReasons() async {
    emit(GetCancelReasonLoading());

    try {
      final response = await apiService.getCancelReasons();
      if (response != null && response.data != null) {
        emit(GetCancelReasonLoaded(response: response));
      } else {
        emit(GetCancelReasonError(message: 'No data found.'));
      }
    } catch (e) {
      emit(GetCancelReasonError(message: 'Error: $e'));
    }
  }
}
