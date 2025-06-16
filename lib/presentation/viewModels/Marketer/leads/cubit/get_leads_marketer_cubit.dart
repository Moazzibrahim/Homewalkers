// ignore_for_file: unused_field, unused_local_variable

import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'get_leads_marketer_state.dart';

class GetLeadsMarketerCubit extends Cubit<GetLeadsMarketerState> {
  final GetLeadsService _getLeadsService;
  LeadResponse? _originalLeadsResponse; // 🟡 حفظ البيانات الأصلية
  final Map<String, int> _salesLeadCount = {};
  Map<String, int> get salesLeadCount => _salesLeadCount;
  List<String> salesNames = [];
  List<String> teamLeaderNames = [];
  GetLeadsMarketerCubit(this._getLeadsService)
    : super(GetLeadsMarketerInitial());

    Future<void> getLeadsByMarketer() async {
    emit(GetLeadsMarketerLoading());
    try {
      final leadsResponse = await _getLeadsService.getLeadsDataByMarketer();
      _originalLeadsResponse = leadsResponse; // 🟡 حفظ البيانات الأصلية
      final prefs = await SharedPreferences.getInstance();
      final managerName = prefs.getString("markterName");
      // ⬇️ استخراج الأسماء الحقيقية
      final salesSet = <String>{};
      final teamLeaderSet = <String>{};

      for (var lead in leadsResponse.data ?? []) {
        if (lead.sales?.manager?.name == managerName) {
          final salesName = lead.sales?.name;
          final teamLeaderName = lead.sales?.teamleader?.name;

          if (salesName != null && salesName.isNotEmpty) {
            salesSet.add(salesName);
          }
          if (teamLeaderName != null && teamLeaderName.isNotEmpty) {
            teamLeaderSet.add(teamLeaderName);
          }
        }
      }
      salesNames = salesSet.toList();
      teamLeaderNames = teamLeaderSet.toList();
      log("✅ تم جلب البيانات بنجاح.");
      emit(GetLeadsMarketerSuccess(leadsResponse));
    } catch (e) {
      log('❌ خطأ في getLeadsByManager: $e');
      emit(const GetLeadsMarketerFailure(" No leads found"));
    }
  }
  Future<void> getLeadsByMarketerInTrash() async {
    emit(GetLeadsMarketerLoading());

    try {
      final leadsResponse = await _getLeadsService.getLeadsDataByMarketerInTrash();
      _originalLeadsResponse = leadsResponse; // 🟡 حفظ البيانات الأصلية
      final prefs = await SharedPreferences.getInstance();
      // ⬇️ استخراج الأسماء الحقيقية
      final salesSet = <String>{};
      final teamLeaderSet = <String>{};

      salesNames = salesSet.toList();
      teamLeaderNames = teamLeaderSet.toList();
      log("✅ تم جلب البيانات بنجاح.");
      emit(GetLeadsMarketerSuccess(leadsResponse));
    } catch (e) {
      log('❌ خطأ في getLeadsByManager: $e');
      emit(const GetLeadsMarketerFailure(" No leads found"));
    }
  }
  void filterLeadsByStageInMarketer(String query) {
    if (_originalLeadsResponse?.data == null) return;
    if (query.isEmpty) {
      emit(GetLeadsMarketerSuccess(_originalLeadsResponse!));
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
    emit(GetLeadsMarketerSuccess(LeadResponse(data: filtered)));
  }
  void filterLeadsMarketer({
    String? name,
    String? email,
    String? phone,
    String? country,
    String? developer,
    String? project,
    String? stage,
    String? channel,
    String? sales,
    String? communicationWay,
    String? campaign,
    String? query,
  }) {
    if (_originalLeadsResponse == null ||
        _originalLeadsResponse!.data == null) {
      emit(GetLeadsMarketerFailure("لا توجد بيانات Leads لفلترتها."));
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
          final matchChannel = channel == null || lead.chanel?.name == channel;
          final matchStage = stage == null || lead.stage?.name == stage;
          final matchSales = sales == null || lead.sales?.name == sales;
          final matchCommunicationWay = communicationWay == null ||
              lead.communicationway?.name == communicationWay;
              final matchCampaign = campaign == null || lead.campaign?.name == campaign;
          return matchQuery &&
              matchCountry &&
              matchDev &&
              matchProject &&
              matchStage &&
              matchChannel &&
              matchSales&&
              matchCommunicationWay&&
              matchCampaign;
        }).toList();
    emit(GetLeadsMarketerSuccess(LeadResponse(data: filtered)));
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
