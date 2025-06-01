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

      log("✅ تم جلب البيانات بنجاح.");
      emit(GetLeadsTeamLeaderSuccess(leadsResponse));
    } catch (e) {
      log('❌ خطأ في getLeadsByTeamLeader: $e');
      emit(const GetLeadsTeamLeaderError("حدث خطأ أثناء تحميل البيانات."));
    }
  }

  void filterLeadsByName(String query) {
    if (_originalLeadsResponse == null) return;

    final filtered = _originalLeadsResponse!.data!
        .where((lead) =>
            lead.name != null &&
            lead.name!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    emit(GetLeadsTeamLeaderSuccess(
      LeadResponse(data: filtered),
    ));
  }

  Future<void> fetchLeadCountPerSales() async {
  try {
    final countMap = await _getLeadsService.getLeadCountPerSales();
    _salesLeadCount = countMap;
    log("✅ عدد الـLeads لكل Sales: $_salesLeadCount");
    // يمكنك إصدار حالة خاصة إذا أردت
    emit(GetLeadsTeamLeaderCountSuccess(_salesLeadCount));
  } catch (e) {
    log('❌ خطأ أثناء جلب عدد الـLeads: $e');
    emit(const GetLeadsTeamLeaderError("حدث خطأ أثناء تحميل عدد الـLeads."));
  }
}
}
