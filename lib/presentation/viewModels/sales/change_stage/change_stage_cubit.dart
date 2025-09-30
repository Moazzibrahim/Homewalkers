import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homewalkers_app/core/constants/apiExceptions.dart';
import 'package:homewalkers_app/data/data_sources/change_stage_api_service.dart';
import 'package:homewalkers_app/data/models/leadStagesModel.dart';
import 'change_stage_state.dart';

class ChangeStageCubit extends Cubit<ChangeStageState> {
  ChangeStageCubit() : super(ChangeStageInitial());

  Future<void> changeStage({required String leadId, required LeadStageRequest request}) async {
    emit(ChangeStageLoading());
    try {
      final data = await ChangeStageApiService.changeStage(
        leadId: leadId,
        request: request,
      );
      log('Stage changed successfully');
      emit(ChangeStageSuccess(data['message'] ?? 'Stage updated successfully'));
    } on ApiException catch (e) {
      log('Error changing stage: ${e.message}');
      emit(ChangeStageError(e.message));
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
      final data = await ChangeStageApiService.postLeadStage(
        leadId: leadId,
        date: date,
        stage: stage,
        sales: sales,
      );
      log('Lead stage posted successfully');
      emit(ChangeStageSuccess(data['message'] ?? 'Lead stage changed successfully'));
    } on ApiException catch (e) {
      log('Error posting lead stage: ${e.message}');
      emit(ChangeStageError(e.message));
    } catch (e) {
      emit(ChangeStageError(e.toString()));
    }
  }
}
