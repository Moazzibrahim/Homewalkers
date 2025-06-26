import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/create_lead_api_service.dart';

part 'create_lead_state.dart';

class CreateLeadCubit extends Cubit<CreateLeadState> {
  final CreateLeadApiService apiService;

  CreateLeadCubit(this.apiService) : super(CreateLeadInitial());

  Future<void> createLead({
    required String name,
    required String email,
    required String phone,
    required String project,
    required String sales,
    required String notes,
    required bool assign,
    required String stage,
    required String chanel,
    required String communicationway,
    required String leedtype,
    required String dayonly,
    required String lastStageDateUpdated,
    required String campaign,
  }) async {
    emit(CreateLeadLoading());
    try {
      await apiService.createLead(
        name: name,
        email: email,
        phone: phone,
        project: project,
        sales: sales,
        notes: notes,
        assign: assign,
        stage: stage,
        chanel: chanel,
        communicationway: communicationway,
        leedtype: leedtype,
        dayonly: dayonly,
        lastStageDateUpdated: lastStageDateUpdated,
        campaign: campaign,
      );
      emit(const CreateLeadSuccess('Lead created successfully.'));
    } catch (e) {
      emit(CreateLeadFailure(e.toString()));
    }
  }
}
