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
    String? phone2,
    String? whatsappNumber,
    String? name,
    String? salesIdd,
    String? email,
    String? project,
    String? notes,
    String? stage,
    String? chanel,
    String? communicationway,
    String? leedtype,
    String? dayonly,
    String? campaign,
    String? lastStageDateUpdated,
    bool? isLeadActivte,
  }) async {
    emit(EditLeadLoading());

    try {
      await apiService.editLead(
        userId: userId,
        phone: phone,
        phone2: phone2,
        whatsappNumber: whatsappNumber,
        name: name,
        salesIdd: salesIdd,
        email: email,
        project: project,
        notes: notes,
        stage: stage,
        chanel: chanel,
        communicationway: communicationway,
        leedtype: leedtype,
        dayonly: dayonly,
        campaign: campaign,
        lastStageDateUpdated: lastStageDateUpdated,
        islLeadactivte: isLeadActivte,
      );
      emit(EditLeadSuccess());
    } catch (e) {
      emit(EditLeadFailure(error: e.toString()));
    }
  }

    Future<void> editLeadAssignvalue({
    required String userId,
    bool? assign,
  }) async {
    emit(EditLeadLoading());

    try {
      await apiService.editLeadAssignValue(
        userId: userId,
        assign: assign
      );
      emit(EditLeadSuccess());
    } catch (e) {
      emit(EditLeadFailure(error: e.toString()));
    }
  }
}
