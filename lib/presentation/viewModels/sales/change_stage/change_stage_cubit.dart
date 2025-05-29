import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/data/data_sources/change_stage_api_service.dart';
import 'change_stage_state.dart';
import 'dart:convert';

class ChangeStageCubit extends Cubit<ChangeStageState> {
  ChangeStageCubit() : super(ChangeStageInitial());

  Future<void> changeStage({
    required String leadId,
    required String laststagedateupdated,
    required String stagedateupdated,
    required String stage,
    String? unitPrice,
  }) async {
    emit(ChangeStageLoading());
    try {
      final response = await ChangeStageApiService.changeStage(
        leadId: leadId,
        datebydayonly: laststagedateupdated,
        stage: stage,
        dateupdated: stagedateupdated,
        unitPrice: unitPrice,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Stage changed successfully');
        log("message:$stage");

        emit(
          ChangeStageSuccess(data['message'] ?? 'Stage updated successfully'),
        );
      } else {
        final error = jsonDecode(response.body);
        log('Error changing stage');
        emit(ChangeStageError(error['message'] ?? 'Failed to update stage'));
      }
    } catch (e) {
      emit(ChangeStageError(e.toString()));
    }
  }

  Future<void> postLeadStage({
    required String leadId,
    required String date,
    required String stage,
    required String sales,
  }) async {
    emit(ChangeStageLoading());
    try {
      final response = await ChangeStageApiService.postLeadStage(
        leadId: leadId,
        date: date,
        stage: stage,
        sales: sales,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        log('Lead stage posted successfully');
        log("sales id: $sales");
        log("stage: $stage");
        emit(
          ChangeStageSuccess(
            data['message'] ?? 'Lead stage posted successfully',
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        log('Error posting lead stage');
        emit(ChangeStageError(error['message'] ?? 'Failed to post lead stage'));
      }
    } catch (e) {
      emit(ChangeStageError(e.toString()));
    }
  }
}
