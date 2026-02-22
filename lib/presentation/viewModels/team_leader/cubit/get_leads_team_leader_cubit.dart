// ignore_for_file: unused_element

import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/data/models/teamleader_pagination_leads_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'get_leads_team_leader_state.dart';

class GetLeadsTeamLeaderCubit extends Cubit<GetLeadsTeamLeaderState> {
  final GetLeadsService _getLeadsService;

  LeadResponse? _originalLeadsResponse;
  Map<String, int> _salesLeadCount = {};
  Map<String, int> get salesLeadCount => _salesLeadCount;

  List<String> salesNames = [];
  List<String> teamLeaderNames = [];
  List<LeadDataPagination> paginatedLeads = [];
  bool hasMoreData = true;
  bool isFetchingMore = false;
  int currentPage = 1;

  GetLeadsTeamLeaderCubit(this._getLeadsService)
    : super(GetLeadsTeamLeaderInitial());

  Future<void> fetchTeamLeaderLeadsWithPagination({
  int limit = 1000,
  bool isLoadMore = false,
  String? search,
  String? salesId,
  String? developerId,
  String? projectId,
  String? channelId,
  String? stageId,
  DateTime? stageDateFrom,
  DateTime? stageDateTo,
  DateTime? creationDateFrom,
  DateTime? creationDateTo,
  bool? data,
  bool? transferefromdata,
  bool resetPagination = false,
}) async {
  // ✅ منع التحميل المتكرر
  if (isFetchingMore) {
    log("🔄 Already fetching more data...");
    return;
  }

  // ✅ إعادة تعيين البيانات إذا طلب المستخدم ذلك
  if (resetPagination) {
    currentPage = 1;
    hasMoreData = true;
    paginatedLeads.clear();
    log("🔄 Pagination reset - clearing all data");
  }

  // ✅ Handle initial load vs load more
  if (!isLoadMore) {
    // Initial load or refresh
    currentPage = 1;
    hasMoreData = true;
    paginatedLeads.clear();
    emit(GetLeadsTeamLeaderPaginationLoading());
  } else {
    // Load more - check if there's more data
    if (!hasMoreData) {
      log("📭 No more data to load");
      return;
    }
    isFetchingMore = true;
    // Don't emit loading state for load more, just show indicator in UI
    // The UI will handle showing the loading indicator at the bottom
  }

  try {
    // ✅ تحديد الصفحة المطلوبة للتحميل
    // إذا كان تحميل إضافي، نستخدم currentPage + 1
    // إذا كان تحميل عادي، نستخدم currentPage (التي تكون 1)
    final int pageToFetch = isLoadMore ? currentPage + 1 : currentPage;
    
    log("📡 Fetching page $pageToFetch with limit $limit...");
    log("🚀 Sending request with page: $pageToFetch");

    final result = await _getLeadsService.fetchTeamLeaderLeadsWithPagination(
      page: pageToFetch,
      limit: limit,
      search: search,
      salesId: salesId,
      developerId: developerId,
      projectId: projectId,
      channelId: channelId,
      stageId: stageId,
      stageDateFrom: stageDateFrom,
      stageDateTo: stageDateTo,
      creationDateFrom: creationDateFrom,
      creationDateTo: creationDateTo,
      data: data,
      transferefromdata: transferefromdata,
    );

    if (result != null && result.data != null) {
      final newData = result.data!;

      if (newData.isEmpty) {
        // No more data
        hasMoreData = false;
        log("📭 No more data - page $pageToFetch is empty");

        if (paginatedLeads.isEmpty) {
          emit(GetLeadsTeamLeaderPaginationEmpty());
        } else {
          final updatedModel = TeamleaderPaginationLeadsModel(
            data: List.from(paginatedLeads),
          );
          emit(GetLeadsTeamLeaderPaginationSuccess(updatedModel));
        }
      } else {
        // Add new data
        paginatedLeads.addAll(newData);

        // ✅ تحديث currentPage بناءً على الصفحة التي تم تحميلها بنجاح
        if (isLoadMore) {
          // إذا كان تحميل إضافي، currentPage تصبح هي pageToFetch
          currentPage = pageToFetch;
        } else {
          // إذا كان تحميل عادي، currentPage تبقى 1 (أو يتم تحديثها حسب الحاجة)
          currentPage = 1;
        }

        // ✅ التحقق مما إذا كان هناك المزيد من البيانات
        // إذا كان عدد العناصر المستلمة يساوي الحد الأقصى، فمن المحتمل أن هناك المزيد
        hasMoreData = newData.length >= limit;

        log(
          "✅ Added ${newData.length} leads. Total: ${paginatedLeads.length}, "
          "Current page: $currentPage, Next page: ${currentPage + 1}, "
          "Has more: $hasMoreData",
        );

        final updatedModel = TeamleaderPaginationLeadsModel(
          data: List.from(paginatedLeads),
        );
        emit(GetLeadsTeamLeaderPaginationSuccess(updatedModel));
      }
    } else {
      if (!isLoadMore) {
        emit(GetLeadsTeamLeaderPaginationError("No leads found"));
      } else {
        hasMoreData = false;
        log("📭 No data received - setting hasMoreData to false");
      }
    }
  } catch (e) {
    log("❌ Error fetching leads: $e");
    if (!isLoadMore) {
      emit(
        GetLeadsTeamLeaderPaginationError(
          "Failed to load leads with pagination: ${e.toString()}",
        ),
      );
    } else {
      // في حالة خطأ أثناء التحميل الإضافي، لا نغير hasMoreData
      // لكن نعطي المستخدم فرصة للمحاولة مرة أخرى
      log("❌ Error during load more: $e");
    }
  } finally {
    isFetchingMore = false;
    log("🔓 isFetchingMore set to false");
  }
}

  /// جلب البيانات مع حساب عدد الـ leads حسب كل مرحلة
  Future<void> getLeadsByTeamLeader({
    bool showLoading = true,
    bool? transferfromdata,
    bool? data,
  }) async {
    if (showLoading) emit(GetLeadsTeamLeaderLoading());

    try {
      final leadsResponse = await _getLeadsService.getLeadsDataByTeamLeader(
        transferfromdata: transferfromdata,
        data: data,
      );

      _originalLeadsResponse = leadsResponse;
      _salesLeadCount = await _getLeadsService.getLeadCountPerStage();

      final salesSet = <String>{};
      final teamLeaderSet = <String>{};

      for (var lead in leadsResponse.data ?? []) {
        final salesName = lead.sales?.userlog?.name;
        final teamLeaderName = lead.sales?.teamleader?.name;

        if (salesName?.isNotEmpty == true) salesSet.add(salesName!);
        if (teamLeaderName?.isNotEmpty == true)
          // ignore: curly_braces_in_flow_control_structures
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
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('name') ?? '';
      if (q == 'fresh') {
        filtered =
            _originalLeadsResponse!.data!.where((lead) {
              final assignedToMe =
                  lead.sales?.userlog?.name?.toLowerCase() ==
                  name.toLowerCase();

              final stageName = lead.stage?.name;
              final isNoStage = stageName?.toLowerCase() == 'no stage';

              return assignedToMe && isNoStage;
            }).toList();
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
    // ✅ لو مفيش Leads
    if (filtered.isEmpty) {
      emit(const GetLeadsTeamLeaderError('No leads found'));
      return;
    }
    emit(GetLeadsTeamLeaderSuccess(LeadResponse(data: filtered)));
  }

  Future<void> refreshLeads({String? stageName}) async {
    await getLeadsByTeamLeader(); // جلب كل الليدز
    if (stageName != null && stageName.isNotEmpty) {
      filterLeadsByStage(stageName); // فلترة حسب stageName لو موجود
    }
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

    final filtered =
        _originalLeadsResponse!.data!.where((lead) {
          final stageMatch =
              (lead.stage?.name?.toLowerCase() ?? '') == stage.toLowerCase();

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
                cleanedLeadPhone.contains(
                  cleanedQDigits.replaceFirst('971', ''),
                ) ||
                cleanedLeadPhone.startsWith(cleanedQDigits);
          }

          final matchQuery = q.isEmpty || matchName || matchEmail || matchPhone;

          return stageMatch && matchQuery;
        }).toList();

    emit(GetLeadsTeamLeaderSuccess(LeadResponse(data: filtered)));
  }

  Future<void> filterPendingLeadsForLoggedSales() async {
    if (_originalLeadsResponse?.data == null) return;

    final prefs = await SharedPreferences.getInstance();
    final salesName = prefs.getString('name')?.toLowerCase() ?? '';

    final filtered =
        _originalLeadsResponse!.data!.where((lead) {
          final stageName = lead.stage?.name?.toLowerCase();
          final leadSalesName = lead.sales?.userlog?.name?.toLowerCase();

          return stageName == 'pending' && leadSalesName == salesName;
        }).toList();

    // ترتيب حسب آخر تحديث للـ stage
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
    log("sales name: $salesName");

    if (filtered.isEmpty) {
      emit(const GetLeadsTeamLeaderError('No pending leads found'));
      return;
    }

    emit(GetLeadsTeamLeaderSuccess(LeadResponse(data: filtered)));
  }
}
