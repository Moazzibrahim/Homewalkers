import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';// ✅ استيراد الخدمة
part 'get_leads_team_leader_state.dart';

class GetLeadsTeamLeaderCubit extends Cubit<GetLeadsTeamLeaderState> {
  final GetLeadsService _getLeadsService;

  GetLeadsTeamLeaderCubit(this._getLeadsService)
      : super(GetLeadsTeamLeaderInitial());

  Future<void> getLeadsByTeamLeader() async {
    emit(GetLeadsTeamLeaderLoading());

    try {
      final leadsResponse = await _getLeadsService.getLeadsDataByTeamLeader();
      log("✅ تم جلب البيانات بنجاح.");
      emit(GetLeadsTeamLeaderSuccess(leadsResponse));
    } catch (e) {
      log('❌ خطأ في getLeadsByTeamLeader: $e');
      emit(const GetLeadsTeamLeaderError("حدث خطأ أثناء تحميل البيانات."));
    }
  }
}
