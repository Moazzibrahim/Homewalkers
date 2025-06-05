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
  List<String> salesNames = [];
  List<String> teamLeaderNames = [];

  GetLeadsTeamLeaderCubit(this._getLeadsService)
    : super(GetLeadsTeamLeaderInitial());

  Future<void> getLeadsByTeamLeader() async {
    emit(GetLeadsTeamLeaderLoading());

    try {
      final leadsResponse = await _getLeadsService.getLeadsDataByTeamLeader();
      _originalLeadsResponse = leadsResponse; // 🟡 حفظ البيانات الأصلية
      // تحميل عدد الـ leads لكل مرحلة
      _salesLeadCount = await _getLeadsService.getLeadCountPerStage();
      final salesSet = <String>{};
      final teamLeaderSet = <String>{};

      for (var lead in leadsResponse.data ?? []) {
        final salesName = lead.sales?.userlog?.name;
        final teamLeaderName = lead.sales?.teamleader?.name;

        if (salesName != null && salesName.isNotEmpty) salesSet.add(salesName);
        if (teamLeaderName != null && teamLeaderName.isNotEmpty) {
          teamLeaderSet.add(teamLeaderName);
        }
      }
      salesNames = salesSet.toList();
      teamLeaderNames = teamLeaderSet.toList();
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

  void filterLeadsManager({
    String? name,
    String? email,
    String? phone,
    String? country,
    String? developer,
    String? project,
    String? stage,
    String? sales,
    String? teamleader,
    String? query,
  }) {
    if (_originalLeadsResponse == null ||
        _originalLeadsResponse!.data == null) {
      emit(GetLeadsTeamLeaderError("لا توجد بيانات Leads لفلترتها."));
      return;
    }
    final filtered =
        _originalLeadsResponse!.data!.where((lead) {
          final q = query?.toLowerCase() ?? '';
          final matchName = lead.name?.toLowerCase().contains(q) ?? false;
          final matchEmail = lead.email?.toLowerCase().contains(q) ?? false;
          final matchPhone = lead.phone?.contains(q) ?? false;
          // matchQuery يبحث في الـ 3 مع بعض
          final matchQuery = q.isEmpty || matchName || matchEmail || matchPhone;
          final leadPhoneCode =
              lead.phone != null ? getPhoneCodeFromPhone(lead.phone!) : null;
          final matchCountry =
              country == null || leadPhoneCode?.startsWith(country) == true;
          final matchDev =
              developer == null || lead.project?.developer?.name == developer;
          final matchProject = project == null || lead.project?.name == project;
          final matchStage = stage == null || lead.stage?.name == stage;
          final matchSales =
              sales == null || lead.sales?.userlog?.name == sales;
          final matchTeamLeader =
              teamleader == null || lead.sales?.teamleader?.name == teamleader;
          return matchQuery &&
              matchCountry &&
              matchDev &&
              matchProject &&
              matchStage &&
              matchSales &&
              matchTeamLeader;
        }).toList();
    emit(GetLeadsTeamLeaderSuccess(LeadResponse(data: filtered)));
  }

  String? getPhoneCodeFromPhone(String phone) {
    String cleanedPhone = phone.replaceAll(RegExp(r'\D'), '');
    for (int i = 4; i >= 1; i--) {
      if (cleanedPhone.length >= i) {
        return cleanedPhone.substring(0, i);
      }
    }
    return null;
  }
}
