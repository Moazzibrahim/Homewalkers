// get_leads_marketer_cubit.dart
// ignore_for_file: unused_field, unused_local_variable, avoid_print, prefer_final_fields
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/data/models/marketer_dashboard_model.dart';
import 'package:homewalkers_app/data/models/new_marketer_pagination_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'get_leads_marketer_state.dart';

class GetLeadsMarketerCubit extends Cubit<GetLeadsMarketerState> {
  final GetLeadsService _getLeadsService;
  LeadResponse? _originalLeadsResponse;
  final Map<String, int> _salesLeadCount = {};
  List<LeadData>? _currentFilteredLeads;

  // ✅ Pagination variables
  NewMarketerPaginationModel? _paginationResponse;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _limit = 10;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  // ✅ Store leads in the correct type (List<Datum>)
  List<Datum> leadsDatum = [];

  // ✅ Store current filters for pagination
  Map<String, dynamic> _currentFilters = {};

  // Getters
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasMoreData => _hasMoreData;
  bool get isLoadingMore => _isLoadingMore;
  Map<String, int> get salesLeadCount => _salesLeadCount;

  List<String> salesNames = [];
  List<String> teamLeaderNames = [];
  List<LeadData> leads = []; // Leave this for backward compatibility

  GetLeadsMarketerCubit(this._getLeadsService)
    : super(GetLeadsMarketerInitial());

  Future<void> fetchMarketerDashboard() async {
    emit(GetMarketerDashboardLoading());

    try {
      final dashboardModel = await _getLeadsService.fetchMarketerDashboard();
      log("✅ Marketer dashboard loaded successfully");
      log("Total Leads: ${dashboardModel.totalLeads}");
      emit(GetMarketerDashboardSuccess(dashboardModel));
    } catch (e) {
      log("❌ Error loading marketer dashboard: $e");
      emit(GetMarketerDashboardFailure("Failed to load dashboard data"));
    }
  }

  Future<void> fetchMarketerDataDashboard() async {
    emit(GetMarketerDashboardLoading());

    try {
      final dashboardModel =
          await _getLeadsService.fetchMarketerDataDashboard();
      log("✅ Marketer data dashboard loaded successfully");
      log("Total Leads: ${dashboardModel.totalLeads}");
      emit(GetMarketerDashboardSuccess(dashboardModel));
    } catch (e) {
      log("❌ Error loading marketer data dashboard: $e");
      emit(GetMarketerDashboardFailure("Failed to load dashboard data"));
    }
  }
  // أضف هذه الدالة في نهاية class GetLeadsMarketerCubit

  Future<void> fetchLeadsMarketerWithPagination({
    bool refresh = false,
    String? search,
    List<String>? salesIds,
    List<String>? developerIds,
    List<String>? projectIds,
    List<String>? channelIds,
    List<String>? campaignIds,
    List<String>? communicationWayIds,
    List<String>? stageIds,
    List<String>? addedByIds,
    List<String>? assignedFromIds,
    List<String>? assignedToIds,
    DateTime? stageDateFrom,
    DateTime? stageDateTo,
    DateTime? creationDateFrom,
    DateTime? creationDateTo,
    DateTime? lastStageUpdateFrom,
    DateTime? lastStageUpdateTo,
    DateTime? lastCommentDateFrom,
    DateTime? lastCommentDateTo,
    bool? duplicates,
    bool? ignoreDuplicate,
    bool? data,
    bool? transferefromdata,
  }) async {
    // إذا كان refresh = true، نعيد تعيين الصفحة إلى 1 ونمسح البيانات القديمة
    if (refresh) {
      _currentPage = 1;
      leadsDatum.clear();
      _hasMoreData = true;
      _paginationResponse = null;

      // حفظ الفلاتر الحالية للاستخدام في التحميلات اللاحقة
      _currentFilters = {
        'search': search,
        'salesIds': salesIds,
        'developerIds': developerIds,
        'projectIds': projectIds,
        'channelIds': channelIds,
        'campaignIds': campaignIds,
        'communicationWayIds': communicationWayIds,
        'stageIds': stageIds,
        'addedByIds': addedByIds,
        'assignedFromIds': assignedFromIds,
        'assignedToIds': assignedToIds,
        'stageDateFrom': stageDateFrom,
        'stageDateTo': stageDateTo,
        'creationDateFrom': creationDateFrom,
        'creationDateTo': creationDateTo,
        'lastStageUpdateFrom': lastStageUpdateFrom,
        'lastStageUpdateTo': lastStageUpdateTo,
        'lastCommentDateFrom': lastCommentDateFrom,
        'lastCommentDateTo': lastCommentDateTo,
        'duplicates': duplicates,
        'ignoreDuplicate': ignoreDuplicate,
        'data': data,
        'transferefromdata': transferefromdata,
      };
    }

    // التحقق من وجود المزيد من البيانات
    if (!_hasMoreData && !refresh) {
      log("📌 No more data to load");
      return;
    }

    // منع التحميل المتزامن
    if (_isLoadingMore && !refresh) {
      log("⏳ Already loading more data...");
      return;
    }

    _isLoadingMore = !refresh; // إذا كان refresh، لا نعتبره تحميل للمزيد
    emit(
      GetLeadsMarketerPaginationLoading(
        isLoadingMore: !refresh,
        currentPage: _currentPage,
      ),
    );

    try {
      log(
        "📥 Fetching page $_currentPage ${refresh ? '(refresh)' : '(load more)'}",
      );

      final response = await _getLeadsService.fetchleadsMarketerWithPagination(
        page: _currentPage,
        limit: _limit,
        search: search,
        salesIds: salesIds,
        developerIds: developerIds,
        projectIds: projectIds,
        channelIds: channelIds,
        campaignIds: campaignIds,
        communicationWayIds: communicationWayIds,
        stageIds: stageIds,
        addedByIds: addedByIds,
        assignedFromIds: assignedFromIds,
        assignedToIds: assignedToIds,
        stageDateFrom: stageDateFrom,
        stageDateTo: stageDateTo,
        creationDateFrom: creationDateFrom,
        creationDateTo: creationDateTo,
        lastStageUpdateFrom: lastStageUpdateFrom,
        lastStageUpdateTo: lastStageUpdateTo,
        lastCommentDateFrom: lastCommentDateFrom,
        lastCommentDateTo: lastCommentDateTo,
        duplicates: duplicates,
        ignoreDuplicate: ignoreDuplicate,
        data: data,
        transferefromdata: transferefromdata,
      );

      // تحديث معلومات الباجينيشن
      _paginationResponse = response;
      _totalItems = (response.pagination?.totalItems ?? 0).toInt();
      _totalPages = (response.pagination?.numberOfPages ?? 1).toInt();

      // التحقق من وجود المزيد من الصفحات
      if (_currentPage >= _totalPages) {
        _hasMoreData = false;
        log("📌 No more pages. Current: $_currentPage, Total: $_totalPages");
      } else {
        _hasMoreData = true;
      }

      // إضافة البيانات الجديدة إلى القائمة
      if (response.data != null && response.data!.isNotEmpty) {
        if (refresh) {
          // في حالة التحديث، نستبدل البيانات بالكامل
          leadsDatum = response.data!;
          log("🔄 Refreshed data: ${leadsDatum.length} leads");
        } else {
          // في حالة التحميل للمزيد، نضيف البيانات الجديدة
          leadsDatum.addAll(response.data!);
          log(
            "➕ Added ${response.data!.length} leads. Total: ${leadsDatum.length}",
          );
        }

        // زيادة رقم الصفحة للطلب القادم
        _currentPage++;
      } else {
        _hasMoreData = false;
        log("📌 Reached last page. No more data.");
      }

      _isLoadingMore = false;
      emit(GetLeadsMarketerPaginationSuccess(paginationModel: response));
    } catch (e) {
      _isLoadingMore = false;
      log('❌ Error in fetchLeadsMarketerWithPagination: $e');
      emit(
        GetLeadsMarketerPaginationFailure(
          'Failed to load leads: $e',
          isLoadingMore: !refresh,
        ),
      );
    }
  }

  // أضف هذه الدالة في نهاية class GetLeadsMarketerCubit
  void resetState() {
    log("🔄 Resetting Cubit state...");

    // إعادة تعيين المتغيرات
    _paginationResponse = null;
    _currentPage = 1;
    _totalPages = 1;
    _totalItems = 0;
    _limit = 10;
    _hasMoreData = true;
    _isLoadingMore = false;

    // مسح البيانات
    leadsDatum.clear();

    // مسح الفلاتر
    _currentFilters = {};

    // إصدار حالة Initial
    emit(GetLeadsMarketerInitial());
  }

  // دالة مساعدة لإعادة تحميل الصفحة الأولى (للسحب للتحديث)
  Future<void> refreshLeadsMarketer() async {
    log("🔄 Refreshing leads with current filters...");

    // استخدام الفلاتر المحفوظة أو قيم افتراضية
    await fetchLeadsMarketerWithPagination(
      refresh: true,
      search: _currentFilters['search'] as String?,
      salesIds: _currentFilters['salesIds'] as List<String>?,
      developerIds: _currentFilters['developerIds'] as List<String>?,
      projectIds: _currentFilters['projectIds'] as List<String>?,
      channelIds: _currentFilters['channelIds'] as List<String>?,
      campaignIds: _currentFilters['campaignIds'] as List<String>?,
      communicationWayIds:
          _currentFilters['communicationWayIds'] as List<String>?,
      stageIds: _currentFilters['stageIds'] as List<String>?,
      addedByIds: _currentFilters['addedByIds'] as List<String>?,
      assignedFromIds: _currentFilters['assignedFromIds'] as List<String>?,
      assignedToIds: _currentFilters['assignedToIds'] as List<String>?,
      stageDateFrom: _currentFilters['stageDateFrom'] as DateTime?,
      stageDateTo: _currentFilters['stageDateTo'] as DateTime?,
      creationDateFrom: _currentFilters['creationDateFrom'] as DateTime?,
      creationDateTo: _currentFilters['creationDateTo'] as DateTime?,
      lastStageUpdateFrom: _currentFilters['lastStageUpdateFrom'] as DateTime?,
      lastStageUpdateTo: _currentFilters['lastStageUpdateTo'] as DateTime?,
      lastCommentDateFrom: _currentFilters['lastCommentDateFrom'] as DateTime?,
      lastCommentDateTo: _currentFilters['lastCommentDateTo'] as DateTime?,
      duplicates: _currentFilters['duplicates'] as bool?,
      ignoreDuplicate: _currentFilters['ignoreDuplicate'] as bool?,
      data: _currentFilters['data'] as bool?,
      transferefromdata: _currentFilters['transferefromdata'] as bool?,
    );
  }

  // دالة لتحميل الصفحة التالية (للسكرول)
  Future<void> loadNextPage() async {
    if (!_hasMoreData || _isLoadingMore) {
      log(
        "📌 Cannot load more: hasMoreData=$_hasMoreData, isLoadingMore=$_isLoadingMore",
      );
      return;
    }

    log("➡️ Loading next page $_currentPage...");

    await fetchLeadsMarketerWithPagination(
      refresh: false,
      search: _currentFilters['search'] as String?,
      salesIds: _currentFilters['salesIds'] as List<String>?,
      developerIds: _currentFilters['developerIds'] as List<String>?,
      projectIds: _currentFilters['projectIds'] as List<String>?,
      channelIds: _currentFilters['channelIds'] as List<String>?,
      campaignIds: _currentFilters['campaignIds'] as List<String>?,
      communicationWayIds:
          _currentFilters['communicationWayIds'] as List<String>?,
      stageIds: _currentFilters['stageIds'] as List<String>?,
      addedByIds: _currentFilters['addedByIds'] as List<String>?,
      assignedFromIds: _currentFilters['assignedFromIds'] as List<String>?,
      assignedToIds: _currentFilters['assignedToIds'] as List<String>?,
      stageDateFrom: _currentFilters['stageDateFrom'] as DateTime?,
      stageDateTo: _currentFilters['stageDateTo'] as DateTime?,
      creationDateFrom: _currentFilters['creationDateFrom'] as DateTime?,
      creationDateTo: _currentFilters['creationDateTo'] as DateTime?,
      lastStageUpdateFrom: _currentFilters['lastStageUpdateFrom'] as DateTime?,
      lastStageUpdateTo: _currentFilters['lastStageUpdateTo'] as DateTime?,
      lastCommentDateFrom: _currentFilters['lastCommentDateFrom'] as DateTime?,
      lastCommentDateTo: _currentFilters['lastCommentDateTo'] as DateTime?,
      duplicates: _currentFilters['duplicates'] as bool?,
      ignoreDuplicate: _currentFilters['ignoreDuplicate'] as bool?,
      data: _currentFilters['data'] as bool?,
      transferefromdata: _currentFilters['transferefromdata'] as bool?,
    );
  }

  // دالة لتطبيق الفلاتر مع الـ Pagination
  // في get_leads_marketer_cubit.dart - دالة filterLeadsMarketerWithPagination
  Future<void> filterLeadsMarketerWithPagination({
    String? search,
    List<String>? salesIds,
    List<String>? developerIds,
    List<String>? projectIds,
    List<String>? channelIds,
    List<String>? campaignIds,
    List<String>? communicationWayIds,
    List<String>? stageIds,
    List<String>? addedByIds,
    List<String>? assignedFromIds,
    List<String>? assignedToIds,
    DateTime? stageDateFrom,
    DateTime? stageDateTo,
    DateTime? creationDateFrom,
    DateTime? creationDateTo,
    DateTime? lastStageUpdateFrom,
    DateTime? lastStageUpdateTo,
    DateTime? lastCommentDateFrom,
    DateTime? lastCommentDateTo,
    bool? duplicates,
    bool? ignoreDuplicate,
    bool? data,
    bool? transferefromdata,
  }) async {
    log("🔍 Applying filters with pagination...");
    log("📋 Filters received - salesIds: $salesIds");
    log("📋 Filters received - developerIds: $developerIds");
    log("📋 Filters received - projectIds: $projectIds");
    log("📋 Filters received - stageIds: $stageIds");

    // حفظ الفلاتر الجديدة
    _currentFilters = {
      'search': search,
      'salesIds': salesIds,
      'developerIds': developerIds,
      'projectIds': projectIds,
      'channelIds': channelIds,
      'campaignIds': campaignIds,
      'communicationWayIds': communicationWayIds,
      'stageIds': stageIds,
      'addedByIds': addedByIds,
      'assignedFromIds': assignedFromIds,
      'assignedToIds': assignedToIds,
      'stageDateFrom': stageDateFrom,
      'stageDateTo': stageDateTo,
      'creationDateFrom': creationDateFrom,
      'creationDateTo': creationDateTo,
      'lastStageUpdateFrom': lastStageUpdateFrom,
      'lastStageUpdateTo': lastStageUpdateTo,
      'lastCommentDateFrom': lastCommentDateFrom,
      'lastCommentDateTo': lastCommentDateTo,
      'duplicates': duplicates,
      'ignoreDuplicate': ignoreDuplicate,
      'data': data,
      'transferefromdata': transferefromdata,
    };

    // إعادة تعيين الصفحة وتحميل البيانات الجديدة
    await fetchLeadsMarketerWithPagination(
      refresh: true,
      search: search,
      salesIds: salesIds,
      developerIds: developerIds,
      projectIds: projectIds,
      channelIds: channelIds,
      campaignIds: campaignIds,
      communicationWayIds: communicationWayIds,
      stageIds: stageIds,
      addedByIds: addedByIds,
      assignedFromIds: assignedFromIds,
      assignedToIds: assignedToIds,
      stageDateFrom: stageDateFrom,
      stageDateTo: stageDateTo,
      creationDateFrom: creationDateFrom,
      creationDateTo: creationDateTo,
      lastStageUpdateFrom: lastStageUpdateFrom,
      lastStageUpdateTo: lastStageUpdateTo,
      lastCommentDateFrom: lastCommentDateFrom,
      lastCommentDateTo: lastCommentDateTo,
      duplicates: duplicates,
      ignoreDuplicate: ignoreDuplicate,
      data: data,
      transferefromdata: transferefromdata,
    );
  }

  // دالة مساعدة لمسح الفلاتر
  Future<void> clearFilters() async {
    log("🧹 Clearing all filters...");
    _currentFilters.clear();
    await refreshLeadsMarketer();
  }

  // دالة للحصول على إحصائيات الصفحات الحالية
  Map<String, dynamic> getPaginationStats() {
    return {
      'currentPage': _currentPage - 1, // لأننا نزيدها بعد التحميل الناجح
      'totalPages': _totalPages,
      'totalItems': _totalItems,
      'hasMoreData': _hasMoreData,
      'loadedItemsCount': leadsDatum.length,
      'limit': _limit,
    };
  }

  Future<void> getLeadsByMarketer({
    String? stageFilter,
    bool duplicatesOnly = false,
  }) async {
    emit(GetLeadsMarketerLoading());
    try {
      final leadsResponse = await _getLeadsService.getLeadsDataByMarketer();
      _originalLeadsResponse = leadsResponse;

      final prefs = await SharedPreferences.getInstance();
      final managerName = prefs.getString("markterName");

      final salesSet = <String>{};
      final teamLeaderSet = <String>{};
      leads = List<LeadData>.from(leadsResponse.data ?? []);

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

      List<LeadData>? filteredData = leadsResponse.data;

      if (stageFilter != null && stageFilter.isNotEmpty) {
        filteredData =
            filteredData
                ?.where(
                  (lead) =>
                      lead.stage?.name?.toLowerCase() ==
                      stageFilter.toLowerCase(),
                )
                .toList();
      }

      if (duplicatesOnly) {
        filteredData =
            filteredData
                ?.where((lead) => (lead.allVersions?.length ?? 0) > 1)
                .toList();
      }

      // ✅ إضافة منطق الترتيب حسب أقرب stagedateupdated لتوقيت دبي
      if (filteredData != null && filteredData.isNotEmpty) {
        filteredData.sort((a, b) {
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

          return dateA.compareTo(dateB); // القديم أولاً، الجديد بعده
        });
      }

      log(
        "✅ البيانات الأولية تم جلبها وفلترتها بنجاح. عدد النتائج: ${filteredData?.length ?? 0}",
      );
      log("✅ تم جلب البيانات بنجاح.");
      _currentFilteredLeads = null; // ✅ أضف هذا السطر

      emit(GetLeadsMarketerSuccess(leadsResponse));
    } catch (e) {
      log('❌ خطأ في getLeadsByMarketer: $e');
      emit(const GetLeadsMarketerFailure("No leads found"));
    }
  }

  Future<void> getLeadsByMarketerInTrash() async {
    emit(GetLeadsMarketerLoading());

    try {
      final leadsResponse =
          await _getLeadsService.getLeadsDataByMarketerInTrash();
      _originalLeadsResponse = leadsResponse; // 🟡 حفظ البيانات الأصلية هنا
      final prefs = await SharedPreferences.getInstance();
      // ⬇️ استخراج الأسماء الحقيقية
      final salesSet = <String>{};
      final teamLeaderSet = <String>{};

      // هنا المفروض تستخرج الأسماء زي ما عملت في getLeadsByMarketer
      for (var lead in leadsResponse.data ?? []) {
        final salesName = lead.sales?.name;
        final teamLeaderName = lead.sales?.teamleader?.name;

        if (salesName != null && salesName.isNotEmpty) {
          salesSet.add(salesName);
        }
        if (teamLeaderName != null && teamLeaderName.isNotEmpty) {
          teamLeaderSet.add(teamLeaderName);
        }
      }
      salesNames = salesSet.toList();
      teamLeaderNames = teamLeaderSet.toList();
      log("✅ تم جلب بيانات سلة المهملات بنجاح.");
      _currentFilteredLeads = null; // ✅ أضف هذا السطر

      emit(GetLeadsMarketerSuccess(leadsResponse));
    } catch (e) {
      log('❌ خطأ في getLeadsByMarketerInTrash: $e');
      emit(
        const GetLeadsMarketerFailure("No leads found in trash."),
      ); // رسالة أوضح
    }
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
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastStageUpdateStart,
    DateTime? lastStageUpdateEnd,
    bool duplicatesOnly = false,
  }) {
    if (_originalLeadsResponse == null ||
        _originalLeadsResponse!.data == null) {
      emit(
        const GetLeadsMarketerFailure("No leads data available for filtering."),
      );
      return;
    }

    DateTime getDateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

    DateTime? parseNullableDate(String? dateStr) {
      if (dateStr == null) return null;
      final trimmed = dateStr.trim();
      if (trimmed.isEmpty || trimmed == '-') return null;
      try {
        return DateTime.parse(trimmed);
      } catch (_) {
        return null;
      }
    }

    print("=== FILTER START ===");
    print("Original leads count: ${_originalLeadsResponse!.data!.length}");

    // ✅ نبدأ دائماً من البيانات الأصلية
    List<LeadData> filteredLeads = List.from(_originalLeadsResponse!.data!);

    // ✅ تطبيق فلتر duplicates أولاً إذا كان مطلوباً
    if (duplicatesOnly) {
      filteredLeads =
          filteredLeads
              .where((lead) => (lead.allVersions?.length ?? 0) > 1)
              .toList();
      print("After duplicates filter: ${filteredLeads.length}");
    }

    // ✅ فلترة query (بحث عام)
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase().trim();
      filteredLeads =
          filteredLeads.where((lead) {
            final matchName = lead.name?.toLowerCase().contains(q) ?? false;
            final matchEmail = lead.email?.toLowerCase().contains(q) ?? false;
            final matchPhone = lead.phone?.contains(q) ?? false;
            final matchInVersions =
                (lead.allVersions?.length ?? 0) > 1 &&
                lead.allVersions!.any((v) {
                  return (v.name?.toLowerCase().contains(q) ?? false) ||
                      (v.email?.toLowerCase().contains(q) ?? false) ||
                      (v.phone?.contains(q) ?? false);
                });
            return matchName || matchEmail || matchPhone || matchInVersions;
          }).toList();
      print("After query filter: ${filteredLeads.length}");
    }

    // ✅ فلترة name
    if (name != null && name.isNotEmpty) {
      final n = name.toLowerCase().trim();
      filteredLeads =
          filteredLeads
              .where((lead) => lead.name?.toLowerCase().contains(n) ?? false)
              .toList();
      print("After name filter: ${filteredLeads.length}");
    }

    // ✅ فلترة email
    if (email != null && email.isNotEmpty) {
      final e = email.toLowerCase().trim();
      filteredLeads =
          filteredLeads
              .where((lead) => lead.email?.toLowerCase().contains(e) ?? false)
              .toList();
      print("After email filter: ${filteredLeads.length}");
    }

    // ✅ فلترة phone
    if (phone != null && phone.isNotEmpty) {
      filteredLeads =
          filteredLeads
              .where((lead) => lead.phone?.contains(phone) ?? false)
              .toList();
      print("After phone filter: ${filteredLeads.length}");
    }

    // ✅ باقي الفلاتر
    filteredLeads =
        filteredLeads.where((lead) {
          // فلترة country
          bool matchCountry = true;
          if (country != null && country.isNotEmpty) {
            final leadPhoneCode =
                lead.phone != null ? getPhoneCodeFromPhone(lead.phone!) : null;
            matchCountry =
                leadPhoneCode != null && leadPhoneCode.startsWith(country);
          }

          // فلترة developer
          bool matchDev = true;
          if (developer != null && developer.isNotEmpty) {
            matchDev =
                lead.project?.developer?.name?.toLowerCase() ==
                developer.toLowerCase();
          }

          // فلترة project
          bool matchProject = true;
          if (project != null && project.isNotEmpty) {
            matchProject =
                lead.project?.name?.toLowerCase() == project.toLowerCase();
          }

          // فلترة channel
          bool matchChannel = true;
          if (channel != null && channel.isNotEmpty) {
            matchChannel =
                lead.chanel?.name?.toLowerCase() == channel.toLowerCase();
          }

          // فلترة stage
          bool matchStage = true;
          if (stage != null && stage.isNotEmpty) {
            matchStage = lead.stage?.name?.toLowerCase() == stage.toLowerCase();
          }

          // فلترة sales
          bool matchSales = true;
          if (sales != null && sales.isNotEmpty) {
            final salesName = lead.sales?.name;
            matchSales =
                salesName != null &&
                salesName.trim().toLowerCase() == sales.trim().toLowerCase();
          }

          // فلترة communicationWay
          bool matchCommunicationWay = true;
          if (communicationWay != null && communicationWay.isNotEmpty) {
            matchCommunicationWay =
                lead.communicationway?.name?.toLowerCase() ==
                communicationWay.toLowerCase();
          }

          // فلترة campaign
          bool matchCampaign = true;
          if (campaign != null && campaign.isNotEmpty) {
            matchCampaign =
                lead.campaign?.name?.toLowerCase() == campaign.toLowerCase();
          }

          // فلترة التاريخ
          bool matchDateRange = true;
          if (startDate != null || endDate != null) {
            final recordDate = parseNullableDate(lead.date);
            if (recordDate != null) {
              final recordDateOnly = getDateOnly(recordDate);

              if (startDate != null) {
                final startDateOnly = getDateOnly(startDate);
                matchDateRange =
                    matchDateRange && !recordDateOnly.isBefore(startDateOnly);
              }

              if (endDate != null) {
                final endDateOnly = getDateOnly(endDate);
                matchDateRange =
                    matchDateRange && !recordDateOnly.isAfter(endDateOnly);
              }
            } else {
              matchDateRange = false;
            }
          }

          // فلترة lastStageUpdate
          bool matchLastStageUpdated = true;
          if (lastStageUpdateStart != null || lastStageUpdateEnd != null) {
            final lastStageUpdated = parseNullableDate(
              lead.lastStageDateUpdated,
            );
            if (lastStageUpdated != null) {
              final lastStageUpdatedOnly = getDateOnly(lastStageUpdated);

              if (lastStageUpdateStart != null) {
                final lastStageUpdateStartOnly = getDateOnly(
                  lastStageUpdateStart,
                );
                matchLastStageUpdated =
                    matchLastStageUpdated &&
                    !lastStageUpdatedOnly.isBefore(lastStageUpdateStartOnly);
              }

              if (lastStageUpdateEnd != null) {
                final lastStageUpdateEndOnly = getDateOnly(lastStageUpdateEnd);
                matchLastStageUpdated =
                    matchLastStageUpdated &&
                    !lastStageUpdatedOnly.isAfter(lastStageUpdateEndOnly);
              }
            } else {
              matchLastStageUpdated = false;
            }
          }

          return matchCountry &&
              matchDev &&
              matchProject &&
              matchStage &&
              matchChannel &&
              matchSales &&
              matchCommunicationWay &&
              matchDateRange &&
              matchLastStageUpdated &&
              matchCampaign;
        }).toList();

    print("=== FILTER RESULTS ===");
    print("Final filtered count: ${filteredLeads.length}");

    if (filteredLeads.isEmpty) {
      print("⚠️ No leads match the filters");
      emit(GetLeadsMarketerFailure("No leads found matching your criteria."));
    } else {
      print("✅ Found ${filteredLeads.length} leads");
      filteredLeads.take(3).forEach((lead) {
        print(
          "Lead: ${lead.name}, Sales: ${lead.sales?.name}, Stage: ${lead.stage?.name}",
        );
      });

      // ✅ هنا التعديل المهم - نقوم بإنشاء LeadResponse جديد بالبيانات المفلترة
      final filteredResponse = LeadResponse(data: filteredLeads);

      // ✅ تحديث المتغير leads
      leads = filteredLeads;

      // ✅ إرسال الـ state الجديد مع البيانات المفلترة
      emit(GetLeadsMarketerSuccess(filteredResponse));
    }
  }

  String? getPhoneCodeFromPhone(String phone) {
    String cleanedPhone = phone.replaceAll(RegExp(r'\D'), '');
    // لتبسيط استخراج كود الدولة، عادة ما يكون أول 2-3 أرقام
    // ولكن الطريقة الأكثر دقة هي استخدام مكتبة متخصصة في أرقام الهواتف مثل `phone_number`
    // للتبسيط، نفترض هنا أننا نبحث عن أول رقمين إلى 4 أرقام ككود دولة.
    if (cleanedPhone.length >= 2) {
      if (cleanedPhone.startsWith('20')) return '20'; // Egypt
      if (cleanedPhone.startsWith('966')) return '966'; // Saudi Arabia
      if (cleanedPhone.startsWith('971')) return '971'; // UAE
      // أضف المزيد من أكواد الدول حسب حاجتك
      // أو يمكنك البحث عن الكود في قائمة البلدان المتاحة (selectedCountry?.phoneCode)
      // أفضل حل هو مقارنة الكود بالبداية وليس البحث في cleanedPhone كله
      // مثلاً: لو Country Picker بيرجع "20"
      // يبقى لو رقم التليفون +201012345678 يبقى check lead.phone.startsWith('+'+countryCode)
      // لو الـ selectedCountry.phoneCode هو String، يبقى لازم تقارنه String.

      // هنا أفضل طريقة:
      // return cleanedPhone.substring(0, cleanedPhone.length > 4 ? 4 : cleanedPhone.length);
      // دي ممكن ترجع جزء من الرقم مش كود الدولة بالظبط
      // الأفضل هي الطريقة اللي كنت كاتبها في LeadsMarketierScreen
    }
    return null;
  }

  void filterLeadsMarketerForAdvancedSearch({
    String? sales, // This is the sales ID
    String? country, // This is the country phone code (e.g., "971")
    String? creationDate,
    String? fromDate,
    String? toDate,
    String? user,
    String? commentDate,
  }) {
    if (_originalLeadsResponse == null ||
        _originalLeadsResponse!.data == null) {
      emit(
        const GetLeadsMarketerFailure("No leads data available for filtering."),
      );
      return;
    }

    emit(GetLeadsMarketerLoading()); // Show loading state during filtering

    List<LeadData> filteredLeads = List.from(_originalLeadsResponse!.data!);

    // Parse filter dates once for efficiency
    final DateTime? startDate =
        fromDate != null ? DateTime.tryParse(fromDate)?.toUtc() : null;
    final DateTime? endDate =
        toDate != null ? DateTime.tryParse(toDate)?.toUtc() : null;
    final DateTime? creationDateObj =
        creationDate != null ? DateTime.tryParse(creationDate)?.toUtc() : null;
    final DateTime? commentDateObj =
        commentDate != null ? DateTime.tryParse(commentDate)?.toUtc() : null;

    filteredLeads =
        filteredLeads.where((lead) {
          // --- Sales Filter (by ID) ---
          final matchSales = sales == null || lead.sales?.id == sales;

          // --- Country Filter (by Phone Code) ---
          final String? cleanedLeadPhone = lead.phone?.replaceAll(
            RegExp(r'[^0-9]'),
            '',
          );
          final matchCountry =
              country == null ||
              (cleanedLeadPhone?.startsWith(country) ?? false);

          // --- User Filter ---
          final matchUser =
              user == null ||
              (lead.addby?.name?.toLowerCase() == user.toLowerCase());

          // --- Date Filters ---
          final DateTime? leadCreatedAt =
              lead.createdAt != null
                  ? DateTime.tryParse(lead.createdAt!)?.toUtc()
                  : null;

          // تأكد من صلاحية lastcommentdate (غير null، غير "_"، غير فارغ)
          final bool hasValidCommentDate =
              lead.lastcommentdate != null &&
              lead.lastcommentdate != "_" &&
              lead.lastcommentdate!.isNotEmpty;
          final DateTime? leadCommentDate =
              hasValidCommentDate
                  ? DateTime.tryParse(lead.lastcommentdate!)?.toUtc()
                  : null;

          // تحقق من تاريخ الإنشاء بين fromDate و toDate (شامل)
          final matchFromToDate =
              (startDate == null || endDate == null || leadCreatedAt == null)
                  ? true
                  : (!leadCreatedAt.isBefore(startDate) &&
                      !leadCreatedAt.isAfter(endDate));

          // تحقق من تاريخ الإنشاء يطابق creationDate (نفس اليوم)
          final matchCreationDate =
              (creationDateObj == null || leadCreatedAt == null)
                  ? true
                  : (leadCreatedAt.isAfter(
                        creationDateObj.subtract(
                          const Duration(milliseconds: 1),
                        ),
                      ) &&
                      leadCreatedAt.isBefore(
                        creationDateObj.add(const Duration(days: 1)),
                      ));

          // تحقق من تاريخ التعليق يطابق commentDate (نفس اليوم)
          final matchCommentDate =
              (commentDateObj == null)
                  ? true
                  : (leadCommentDate != null &&
                      leadCommentDate.isAfter(
                        commentDateObj.subtract(
                          const Duration(milliseconds: 1),
                        ),
                      ) &&
                      leadCommentDate.isBefore(
                        commentDateObj.add(const Duration(days: 1)),
                      ));

          // دمج جميع شروط الفلترة
          return matchSales &&
              matchCountry &&
              matchUser &&
              matchFromToDate &&
              matchCreationDate &&
              matchCommentDate;
        }).toList();

    emit(GetLeadsMarketerSuccess(LeadResponse(data: filteredLeads)));
  }

  void resetFilters() {
    if (_originalLeadsResponse == null ||
        _originalLeadsResponse!.data == null) {
      emit(const GetLeadsMarketerFailure("No leads available to reset."));
      return;
    }

    // رجّع الليست الأصلية (نسخة جديدة)
    final resetList = List<LeadData>.from(_originalLeadsResponse!.data!);

    emit(GetLeadsMarketerSuccess(LeadResponse(data: resetList)));

    print("🔄 Filters reset. Restored ${resetList.length} leads.");
  }
}
