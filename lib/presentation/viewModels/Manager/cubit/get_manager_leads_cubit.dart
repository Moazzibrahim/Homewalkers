// ignore_for_file: avoid_print, prefer_final_fields

import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/data/models/manager_new/manager_dashboard_pagination_model.dart';
import 'package:homewalkers_app/data/models/manager_new/manager_leads_pagiantion_model.dart';
part 'get_manager_leads_state.dart';

class GetManagerLeadsCubit extends Cubit<GetManagerLeadsState> {
  final GetLeadsService _getLeadsService;
  LeadResponse? _originalLeadsResponse; // 🟡 حفظ البيانات الأصلية
  Map<String, int> _salesLeadCount = {};
  Map<String, int> get salesLeadCount => _salesLeadCount;
  List<String> salesNames = [];
  List<String> teamLeaderNames = [];
  List<LeadData> leads = [];
  CrmLeadsResponse? _crmLeadsResponse;
  CrmLeadsResponse? get crmLeadsResponse => _crmLeadsResponse;
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isFetching = false;
  List<LeadManager> _allLeads = [];
  List<LeadManager> get allLeads => _allLeads;
  bool _isFetchingMore = false; // ✅ جديد
  bool get isFetchingMore => _isFetchingMore;
  ManagerDashboardPaginationModel? dashboardData; // ✅ متغير جديد
  ManagerDashboardPaginationModel? get dashboardDataS => dashboardData;

  GetManagerLeadsCubit(this._getLeadsService) : super(GetManagerLeadsInitial());

  Future<void> getManagerDashboardCounts() async {
    emit(GetManagerLeadsLoading());

    try {
      log("📊 Fetching Manager Dashboard...");

      final dashboardResponse = await _getLeadsService.fetchManagerDashboard();

      if (dashboardResponse == null || dashboardResponse.data == null) {
        emit(const GetManagerLeadsFailure("No dashboard data"));
        return;
      }
      dashboardData = dashboardResponse;
      emit(GetManagerDashboardSuccess(dashboardResponse));
    } catch (e) {
      log("❌ Error in getManagerDashboardCounts: $e");
      emit(const GetManagerLeadsFailure("Dashboard error"));
    }
  }

  Future<void> getManagerDashboardDataCounts() async {
    emit(GetManagerLeadsLoading());

    try {
      log("📊 Fetching Manager Dashboard...");

      final dashboardResponse =
          await _getLeadsService.fetchManagerDashboardData();

      if (dashboardResponse == null || dashboardResponse.data == null) {
        emit(const GetManagerLeadsFailure("No dashboard data"));
        return;
      }

      emit(GetManagerDashboardSuccess(dashboardResponse));
    } catch (e) {
      log("❌ Error in getManagerDashboardCounts: $e");
      emit(const GetManagerLeadsFailure("Dashboard error"));
    }
  }

  Future<void> getManagerLeadsPagination({
    bool? data,
    int page = 1,
    int limit = 10,
    String? search,
    List<String>? salesIds,
    List<String>? developerIds,
    List<String>? projectIds,
    List<String>? channelIds,
    List<String>? campaignIds,
    List<String>? communicationWayIds,
    List<String>? stageIds,
    DateTime? stageDateFrom,
    DateTime? stageDateTo,
    DateTime? creationDateFrom,
    DateTime? creationDateTo,
    DateTime? lastStageUpdateFrom,
    DateTime? lastStageUpdateTo,
    DateTime? lastCommentDateFrom,
    DateTime? lastCommentDateTo,
    bool? ignoreDuplicate,
    bool? transferefromdata,
  }) async {
    // ✅ منع التكرار أثناء الجلب
    if (_isFetching) return;

    // ✅ لو صفحة جديدة بنشغل الـ isFetchingMore
    if (page > 1) {
      _isFetchingMore = true;
      // ✅ تحديث UI فوراً لإظهار علامة التحميل
      if (_crmLeadsResponse != null) {
        emit(GetManagerCrmLeadsSuccess(_crmLeadsResponse!));
      }
    }

    _isFetching = true;

    // ✅ لو أول صفحة، ننظف البيانات ونظهر الـ Loading
    if (page == 1) {
      emit(GetManagerLeadsLoading());
      _allLeads.clear();
    }

    try {
      log("📊 Fetching Manager Leads | page=$page | data=$data");

      final response = await _getLeadsService.fetchManagerLeads(
        data: data,
        page: page,
        limit: limit,
        search: search,
        salesIds: salesIds,
        developerIds: developerIds,
        projectIds: projectIds,
        channelIds: channelIds,
        campaignIds: campaignIds,
        communicationWayIds: communicationWayIds,
        stageIds: stageIds,
        stageDateFrom: stageDateFrom,
        stageDateTo: stageDateTo,
        creationDateFrom: creationDateFrom,
        creationDateTo: creationDateTo,
        lastStageUpdateFrom: lastStageUpdateFrom,
        lastStageUpdateTo: lastStageUpdateTo,
        lastCommentDateFrom: lastCommentDateFrom,
        lastCommentDateTo: lastCommentDateTo,
        ignoreDuplicate: ignoreDuplicate,
        transferefromdata: transferefromdata,
      );

      if (response.data == null) {
        emit(const GetManagerLeadsFailure("No leads data found"));
        return;
      }

      final newLeads = response.data!.leads ?? [];

      _currentPage = response.data!.pagination?.currentPage?.toInt() ?? page;
      _hasNextPage = response.data!.pagination?.hasNextPage ?? false;

      _allLeads.addAll(newLeads);
      _crmLeadsResponse = response;

      log("✅ Total Loaded Leads: ${_allLeads.length}");

      // ✅ نبعت الـ state مع تحديث الـ data
      emit(GetManagerCrmLeadsSuccess(_crmLeadsResponse!));
    } catch (e) {
      log("❌ Error in getManagerLeadsPagination: $e");
      emit(const GetManagerLeadsFailure("Leads error"));
    } finally {
      // ✅ في النهاية نوقف الجلب
      _isFetching = false;
      _isFetchingMore = false;

      // ✅ تحديث UI مرة أخيرة لإخفاء علامة التحميل
      if (_crmLeadsResponse != null) {
        emit(GetManagerCrmLeadsSuccess(_crmLeadsResponse!));
      }
    }
  }

  // ✅ دالة تحميل المزيد
  Future<void> loadMoreManagerLeads({required bool data}) async {
    // ✅ منع التكرار لو مفيش صفحات تاني أو بنجلب دلوقتي
    if (!_hasNextPage || _isFetching || _isFetchingMore) return;

    await getManagerLeadsPagination(data: data, page: _currentPage + 1);
  }

  void filterLeadsByNameInManager(String query) {
    if (_originalLeadsResponse == null) return;

    final filtered =
        _originalLeadsResponse!.data!
            .where(
              (lead) =>
                  lead.name != null &&
                  lead.name!.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    emit(GetManagerLeadsSuccess(LeadResponse(data: filtered)));
  }

  void filterLeadsByStageInManager(String query) {
    if (_originalLeadsResponse?.data == null) return;

    if (query.isEmpty) {
      emit(GetManagerLeadsSuccess(_originalLeadsResponse!));
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

      // ترتيب مباشر من الأقدم للأحدث
      return dateA.compareTo(dateB);
    });

    emit(GetManagerLeadsSuccess(LeadResponse(data: filtered)));
  }

  void filterLeadsManager({
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
    if (_originalLeadsResponse == null ||
        _originalLeadsResponse!.data == null) {
      emit(GetManagerLeadsFailure("لا توجد بيانات Leads لفلترتها."));
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
              matchDev &&
              matchProject &&
              matchStage &&
              matchChannel &&
              matchDateRange &&
              matchLastStageUpdated &&
              matchSales;
        }).toList();
    emit(GetManagerLeadsSuccess(LeadResponse(data: filtered)));
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

  Map<String, List<LeadData>> getSalesGroupedByTeamLeader() {
    final Map<String, List<LeadData>> grouped = {};
    if (_originalLeadsResponse?.data == null) return {};
    for (final lead in _originalLeadsResponse!.data!) {
      final sales = lead.sales;
      final teamleader = lead.sales?.teamleader;
      final teamLeaderName = sales?.teamleader?.name;
      log(
        "👀 Lead: ${lead.name}, Sales: ${sales?.name}, TeamLeader: $teamLeaderName",
      );
      if (teamLeaderName != null &&
          sales?.name != null &&
          teamleader?.role?.toLowerCase() == "team leader") {
        grouped.putIfAbsent(teamLeaderName, () => []);
        grouped[teamLeaderName]!.add(lead);
      }
    }
    for (final entry in grouped.entries) {
      log('Team Leader: ${entry.key}, Leads Count: ${entry.value.length}');
      for (final lead in entry.value) {
        log('  → Lead: ${lead.name}, Sales: ${lead.sales?.name}');
      }
    }
    return grouped;
  }
}
