import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/marketer/edit_lead_api_service.dart';

part 'edit_lead_state.dart';

class EditLeadCubit extends Cubit<EditLeadState> {
  final EditLeadApiService apiService;

  EditLeadCubit(this.apiService) : super(EditLeadInitial());

  Future<void> editLead({
    required String userId,
    String? phone,
    String? name,
    String? email,
  }) async {
    emit(EditLeadLoading());

    try {
      await apiService.editLead(
        userId: userId,
        phone: phone,
        name: name,
        email: email,
      );
      emit(EditLeadSuccess());
    } catch (e) {
      emit(EditLeadFailure(error: e.toString()));
    }
  }
}
