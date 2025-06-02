import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';

part 'get_leads_team_leader_state.dart';

class GetLeadsTeamLeaderCubit extends Cubit<GetLeadsTeamLeaderState> {
  final GetLeadsService _getLeadsService;

  LeadResponse? _originalLeadsResponse; // 🟡 حفظ البيانات الأصلية
  Map<String, int> _salesLeadCount = {};
  Map<String, int> get salesLeadCount => _salesLeadCount;

  GetLeadsTeamLeaderCubit(this._getLeadsService)
    : super(GetLeadsTeamLeaderInitial());

  Future<void> getLeadsByTeamLeader() async {
    emit(GetLeadsTeamLeaderLoading());

    try {
      final leadsResponse = await _getLeadsService.getLeadsDataByTeamLeader();
      _originalLeadsResponse = leadsResponse; // 🟡 حفظ البيانات الأصلية
      // تحميل عدد الـ leads لكل مرحلة
      _salesLeadCount = await _getLeadsService.getLeadCountPerStage();
      log("✅ تم جلب البيانات بنجاح.");
      emit(GetLeadsTeamLeaderSuccess(leadsResponse));
    } catch (e) {
      log('❌ خطأ في getLeadsByTeamLeader: $e');
      emit(const GetLeadsTeamLeaderError(" error in loading leads."));
    }
  }

  void filterLeadsByName(String query) {
    if (_originalLeadsResponse == null) return;

    final filtered =
        _originalLeadsResponse!.data!
            .where(
              (lead) =>
                  lead.name != null &&
                  lead.name!.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    emit(GetLeadsTeamLeaderSuccess(LeadResponse(data: filtered)));
  }

  void filterLeadsByStage(String query) {
    if (_originalLeadsResponse?.data == null) return;
    if (query.isEmpty) {
      emit(GetLeadsTeamLeaderSuccess(_originalLeadsResponse!));
      return;
    }
    final filtered =
        _originalLeadsResponse!.data!
            .where(
              (lead) =>
                  lead.stage?.name != null &&
                  lead.stage!.name!.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
    emit(GetLeadsTeamLeaderSuccess(LeadResponse(data: filtered)));
  }

  Future<void> loadStageCounts() async {
    try {
      _salesLeadCount = await _getLeadsService.getLeadCountPerStage();
      emit(GetLeadsTeamLeaderStageCountLoaded(_salesLeadCount));
      log("✅ تم تحميل عدد الـ Leads لكل مرحلة: $_salesLeadCount");
    } catch (e) {
      log("❌ خطأ أثناء تحميل عدد الـ Leads لكل مرحلة: $e");
      emit(const GetLeadsTeamLeaderError("فشل في تحميل عدد المراحل."));
    }
  }
}
