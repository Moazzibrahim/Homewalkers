// ignore_for_file: unused_element

import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Future<void> getLeadsByTeamLeader({bool showLoading = true}) async {
    if (showLoading) emit(GetLeadsTeamLeaderLoading());

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

      // ✅ نفس طريقة fetchLeads — إصدار الحالة لتحديث الواجهة
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
  // void filterLeadsByStage(String query) async {
  //   if (_originalLeadsResponse?.data == null) return;
  //   final prefs = await SharedPreferences.getInstance();
  //   final loggedSalesId = prefs.getString('teamleader_userlog_id') ?? '';

  //   List<LeadData> filtered = [];

  //   if (query.isEmpty) {
  //     filtered = _originalLeadsResponse!.data!;
  //   } else {
  //     final q = query.toLowerCase();

  //     if (q == 'fresh') {
  //       // Fresh = No Stage assigned to loggedSalesId
  //       filtered =
  //           _originalLeadsResponse!.data!.where((lead) {
  //             final stage = (lead.stage?.name ?? '').toLowerCase();
  //             final assignedId = lead.sales?.id ?? '';
  //             return stage == 'no stage' && assignedId == loggedSalesId;
  //           }).toList();
  //     } else if (q == 'no stage') {
  //       // No Stage = No Stage not assigned to loggedSalesId
  //       filtered =
  //           _originalLeadsResponse!.data!.where((lead) {
  //             final stage = (lead.stage?.name ?? '').toLowerCase();
  //             final assignedId = lead.sales?.id ?? '';
  //             // تأكد إن المخصص لحد غيرك
  //             return stage == 'no stage' && assignedId != loggedSalesId;
  //           }).toList();
  //     } else {
  //       // باقي الستيجات العادية
  //       filtered =
  //           _originalLeadsResponse!.data!.where((lead) {
  //             return lead.stage?.name?.toLowerCase() == q;
  //           }).toList();
  //     }
  //   }

  //   // ✅ ترتيب حسب تاريخ آخر تحديث للـ Stage
  //   filtered.sort((a, b) {
  //     DateTime? dateA =
  //         a.stagedateupdated != null
  //             ? DateTime.parse(
  //               a.stagedateupdated!,
  //             ).toUtc().add(const Duration(hours: 4))
  //             : null;
  //     DateTime? dateB =
  //         b.stagedateupdated != null
  //             ? DateTime.parse(
  //               b.stagedateupdated!,
  //             ).toUtc().add(const Duration(hours: 4))
  //             : null;

  //     if (dateA == null && dateB == null) return 0;
  //     if (dateA == null) return 1;
  //     if (dateB == null) return -1;

  //     return dateA.compareTo(dateB); // الأقدم للأحدث
  //   });

  //   emit(GetLeadsTeamLeaderSuccess(LeadResponse(data: filtered)));
  // }
    void filterLeadsByStage(String query) async {
    if (_originalLeadsResponse?.data == null) return;

    List<LeadData> filtered = [];

    bool hasNoStage(LeadData lead) {
      final name = lead.stage?.name;
      return name == null || name.trim().isEmpty;
    }

    if (query.isEmpty) {
      filtered = _originalLeadsResponse!.data!;
    } else {
      final q = query.toLowerCase();

      if (q == 'fresh') {
        // ✅ Fresh Stage حقيقي
        filtered =
            _originalLeadsResponse!.data!
                .where((lead) => lead.stage?.name?.toLowerCase() == 'fresh')
                .toList();
      } else if (q == 'no stage') {
        // ✅ No Stage Stage حقيقي
        filtered =
            _originalLeadsResponse!.data!
                .where((lead) => lead.stage?.name?.toLowerCase() == 'no stage')
                .toList();
      } else {
        // باقي ال stages (Done Deal – Follow Up – ...)
        filtered =
            _originalLeadsResponse!.data!
                .where((lead) => lead.stage?.name?.toLowerCase() == q)
                .toList();
      }
    }

    // ✅ ترتيب حسب آخر تحديث
    filtered.sort((a, b) {
      DateTime? dateA =
          a.stagedateupdated != null
              ? DateTime.parse(
                a.stagedateupdated!,
              ).toUtc().add(const Duration(hours: 4))
              : null;
      DateTime? dateB =
          b.stagedateupdated != null
              ? DateTime.parse(
                b.stagedateupdated!,
              ).toUtc().add(const Duration(hours: 4))
              : null;

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateA.compareTo(dateB);
    });

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
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastStageUpdateStart,
    DateTime? lastStageUpdateEnd,
  }) {
    if (_originalLeadsResponse?.data == null) {
      emit(const GetLeadsTeamLeaderError("لا توجد بيانات Leads لفلترتها."));
      return;
    }
    DateTime getDateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

    DateTime? parseNullableDate(String? dateStr) {
      if (dateStr == null) return null;
      final trimmed = dateStr.trim();
      if (trimmed.isEmpty || trimmed == '-') return null;
      DateTime? parsedDate = DateTime.tryParse(trimmed);
      if (parsedDate == null) {
        try {
          parsedDate = DateTime.parse(trimmed);
        } catch (e) {
          return null;
        }
      }
      return parsedDate;
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
          final matchSales = sales == null || lead.sales?.name == sales;
          final recordDate = parseNullableDate(lead.date);
          final recordDateOnly =
              recordDate != null ? getDateOnly(recordDate) : null;
          final startDateOnly =
              startDate != null ? getDateOnly(startDate) : null;
          final endDateOnly = endDate != null ? getDateOnly(endDate) : null;
          final matchDateRange =
              (startDate == null && endDate == null) ||
              (recordDateOnly != null &&
                  (startDateOnly == null ||
                      !recordDateOnly.isBefore(startDateOnly)) &&
                  (endDateOnly == null ||
                      !recordDateOnly.isAfter(endDateOnly)));
          final lastStageUpdated = parseNullableDate(lead.lastStageDateUpdated);
          final lastStageUpdatedOnly =
              lastStageUpdated != null ? getDateOnly(lastStageUpdated) : null;
          final lastStageUpdateStartOnly =
              lastStageUpdateStart != null
                  ? getDateOnly(lastStageUpdateStart)
                  : null;
          final lastStageUpdateEndOnly =
              lastStageUpdateEnd != null
                  ? getDateOnly(lastStageUpdateEnd)
                  : null;
          final matchLastStageUpdated =
              (lastStageUpdateStart == null && lastStageUpdateEnd == null) ||
              (lastStageUpdatedOnly != null &&
                  (lastStageUpdateStartOnly == null ||
                      !lastStageUpdatedOnly.isBefore(
                        lastStageUpdateStartOnly,
                      )) &&
                  (lastStageUpdateEndOnly == null ||
                      !lastStageUpdatedOnly.isAfter(lastStageUpdateEndOnly)));

          return matchQuery &&
              matchCountry &&
              matchDeveloper &&
              matchProject &&
              matchStage &&
              matchChannel &&
              matchDateRange &&
              matchLastStageUpdated &&
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
  void filterLeadsByStageAndQuery(String stage, String query) {
  if (_originalLeadsResponse?.data == null) return;

  final q = query.toLowerCase();
  final cleanedQDigits = q.replaceAll(RegExp(r'\D'), '');

  final filtered = _originalLeadsResponse!.data!.where((lead) {
    final stageMatch = (lead.stage?.name?.toLowerCase() ?? '') == stage.toLowerCase();

    // فلترة الاسم والإيميل والرقم
    final matchName = lead.name?.toLowerCase().contains(q) ?? false;
    final matchEmail = lead.email?.toLowerCase().contains(q) ?? false;

    final leadRawPhone = lead.phone ?? '';
    final cleanedLeadPhone = leadRawPhone.replaceAll(RegExp(r'\D'), '');

    bool matchPhone = false;
    if (cleanedQDigits.isNotEmpty) {
      matchPhone =
          cleanedLeadPhone.contains(cleanedQDigits) ||
          cleanedLeadPhone.endsWith(cleanedQDigits) ||
          cleanedLeadPhone.contains(cleanedQDigits.replaceFirst('971', '')) ||
          cleanedLeadPhone.startsWith(cleanedQDigits);
    }

    final matchQuery = q.isEmpty || matchName || matchEmail || matchPhone;

    return stageMatch && matchQuery;
  }).toList();

  emit(GetLeadsTeamLeaderSuccess(LeadResponse(data: filtered)));
}

}
