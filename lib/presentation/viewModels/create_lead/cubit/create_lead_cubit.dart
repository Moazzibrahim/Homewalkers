// ignore_for_file: non_constant_identifier_names

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/create_lead_api_service.dart';

part 'create_lead_state.dart';

class CreateLeadCubit extends Cubit<CreateLeadState> {
  final CreateLeadApiService apiService;

  CreateLeadCubit(this.apiService) : super(CreateLeadInitial());

  Future<bool> createLead({
    required String name,
    required String email,
    required String phone,
    required String project,
    required String sales,
    required String notes,
    required String chanel,
    required String communicationway,
    required String leedtype,
    required String dayonly,
    required String lastStageDateUpdated,
    required String campaign,
    required String budget,
    // 🔹 الحقول الجديدة: اختياري
    String campaignRedirectLink = '',
    String question1_text = '',
    String question1_answer = '',
    String question2_text = '',
    String question2_answer = '',
    String question3_text = '',
    String question3_answer = '',
    String question4_text = '',
    String question4_answer = '',
    String question5_text = '',
    String question5_answer = '',
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
        chanel: chanel,
        communicationway: communicationway,
        leedtype: leedtype,
        dayonly: dayonly,
        lastStageDateUpdated: lastStageDateUpdated,
        campaign: campaign,
        budget: budget,
        // 🔹 تمرير الحقول الجديدة
        campaignRedirectLink: campaignRedirectLink,
        question1_text: question1_text,
        question1_answer: question1_answer,
        question2_text: question2_text,
        question2_answer: question2_answer,
        question3_text: question3_text,
        question3_answer: question3_answer,
        question4_text: question4_text,
        question4_answer: question4_answer,
        question5_text: question5_text,
        question5_answer: question5_answer,
      );
      emit(const CreateLeadSuccess('Lead created successfully.'));
      return true;
    } catch (e) {
      emit(CreateLeadFailure(e.toString()));
      return false;
    }
  }
}
