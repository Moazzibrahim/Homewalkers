import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';

part 'get_leads_team_leader_state.dart';

class GetLeadsTeamLeaderCubit extends Cubit<GetLeadsTeamLeaderState> {
  final GetLeadsService _getLeadsService;

  LeadResponse? _originalLeadsResponse; // حفظ البيانات الأصلية
  Map<String, int> _salesLeadCount = {};
  Map<String, int> get salesLeadCount => _salesLeadCount;

  List<String> salesNames = [];
  List<String> teamLeaderNames = [];

  GetLeadsTeamLeaderCubit(this._getLeadsService)
    : super(GetLeadsTeamLeaderInitial());

  /// جلب البيانات مع حساب عدد الـ leads حسب كل مرحلة
  Future<void> getLeadsByTeamLeader() async {
    emit(GetLeadsTeamLeaderLoading());

    try {
      final leadsResponse = await _getLeadsService.getLeadsDataByTeamLeader();
      _originalLeadsResponse = leadsResponse;

      _salesLeadCount = await _getLeadsService.getLeadCountPerStage();

      final salesSet = <String>{};
      final teamLeaderSet = <String>{};

      for (var lead in leadsResponse.data ?? []) {
        final salesName = lead.sales?.userlog?.name;
        final teamLeaderName = lead.sales?.teamleader?.name;

        if (salesName?.isNotEmpty == true) salesSet.add(salesName!);
        if (teamLeaderName?.isNotEmpty == true)
          teamLeaderSet.add(teamLeaderName!);
      }

      salesNames = salesSet.toList();
      teamLeaderNames = teamLeaderSet.toList();

      log("✅ تم جلب البيانات بنجاح.");
      emit(GetLeadsTeamLeaderSuccess(leadsResponse));
    } catch (e) {
      log('❌ خطأ في getLeadsByTeamLeader: $e');
      emit(const GetLeadsTeamLeaderError("حدث خطأ أثناء تحميل البيانات."));
    }
  }

  /// فلترة الـ leads حسب الاسم
  void filterLeadsByName(String query) {
    if (_originalLeadsResponse == null) return;

    final filtered =
        _originalLeadsResponse!.data!
            .where(
              (lead) =>
                  lead.name?.toLowerCase().contains(query.toLowerCase()) ??
                  false,
            )
            .toList();

    emit(GetLeadsTeamLeaderSuccess(LeadResponse(data: filtered)));
  }

  /// فلترة الـ leads حسب المرحلة
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
                  lead.stage?.name?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false,
            )
            .toList();

    emit(GetLeadsTeamLeaderSuccess(LeadResponse(data: filtered)));
  }

  /// تحميل عدد الـ leads حسب المرحلة
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

  /// فلترة leads بناءً على عدة معايير
  void filterLeadsTeamLeader({
    String? name,
    String? email,
    String? phone,
    String? country,
    String? developer,
    String? project,
    String? stage,
    String? channel,
    String? sales,
    String? query,
  }) {
    if (_originalLeadsResponse?.data == null) {
      emit(const GetLeadsTeamLeaderError("لا توجد بيانات Leads لفلترتها."));
      return;
    }

    final q = query?.toLowerCase() ?? '';

    final filtered =
        _originalLeadsResponse!.data!.where((lead) {
          final matchName = lead.name?.toLowerCase().contains(q) ?? false;
          final matchEmail = lead.email?.toLowerCase().contains(q) ?? false;
          final matchPhone = lead.phone?.contains(q) ?? false;
          final matchQuery = q.isEmpty || matchName || matchEmail || matchPhone;

          final leadPhoneCode =
              lead.phone != null ? getPhoneCodeFromPhone(lead.phone!) : null;
          final matchCountry =
              country == null || leadPhoneCode?.startsWith(country) == true;

          final matchDeveloper =
              developer == null || lead.project?.developer?.name == developer;
          final matchProject = project == null || lead.project?.name == project;
          final matchStage = stage == null || lead.stage?.name == stage;
          final matchChannel = channel == null || lead.chanel?.name == channel;
          final matchSales =
              sales == null || lead.sales?.name == sales;

          return matchQuery &&
              matchCountry &&
              matchDeveloper &&
              matchProject &&
              matchStage &&
              matchChannel &&
              matchSales;
        }).toList();

    log("🔍 عدد النتائج بعد الفلترة: ${filtered.length}");
    emit(GetLeadsTeamLeaderSuccess(LeadResponse(data: filtered)));
  }

  /// استخراج كود الدولة من رقم الهاتف
  String? getPhoneCodeFromPhone(String phone) {
    final cleanedPhone = phone.replaceAll(RegExp(r'\D'), '');
    for (int i = 4; i >= 1; i--) {
      if (cleanedPhone.length >= i) {
        return cleanedPhone.substring(0, i);
      }
    }
    return null;
  }

  void filterLeadsByStageInTeamLeader(String query) {
    if (_originalLeadsResponse?.data == null) return;
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
}
