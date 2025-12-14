// ignore_for_file: unused_field, unnecessary_null_comparison, avoid_print
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_api_service.dart';
import 'package:homewalkers_app/data/models/lead_stats_model.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:homewalkers_app/data/models/new_admin_users_model.dart';
part 'get_all_users_state.dart';

class GetAllUsersCubit extends Cubit<GetAllUsersState> {
  final GetAllUsersApiService apiService;
  AllUsersModel? _originalLeadsResponse;
  AllUsersModel? get originalLeadsResponse => _originalLeadsResponse;
  LeadResponse? _originalLeadsResponseee;
  final Map<String, int> _salesLeadCount = {};
  Map<String, int> get salesLeadCount => _salesLeadCount;
  List<String> salesNames = [];
  List<String> teamLeaderNames = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  List<Lead> leads = [];
  final List<Lead> _allLeads = []; // كل الداتا هنا
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get hasMoreUsers => _hasMore;
  GetAllUsersCubit(this.apiService) : super(GetAllUsersInitial());

  void clearLeads() {
    leads.clear();
    salesNames.clear();
    _allLeads.clear();
    teamLeaderNames.clear();
    _originalLeadsResponse = null;
    _originalLeadsResponseee = null;
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
    emit(GetAllUsersInitial());
  }

  Future<void> fetchLeadCounts() async {
    try {
      final response = await apiService.getAllUsers();

      if (response != null && response.data != null) {
        final Map<String, int> leadCounts = {};

        for (var lead in response.data!) {
          if (lead.sales?.userlog?.id != null) {
            final salesId = lead.sales!.userlog!.id!;
            leadCounts[salesId] = (leadCounts[salesId] ?? 0) + 1;
          }
        }
        emit(UsersLeadCountSuccess(leadCounts));
      } else {
        emit(const GetAllUsersFailure('Failed to fetch lead counts.'));
      }
    } catch (e) {
      emit(
        GetAllUsersFailure(
          'An error occurred while counting leads: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> fetchAllUsers({
    String? stageFilter,
    bool loadAll = false,
    bool reset = false,
    bool loadMore = false,
    bool? duplicatesOnly,
  }) async {
    if (_isLoading) return;

    if (reset) {
      clearLeads();
      _currentPage = 1;
      _hasMore = true;
    }

    if (loadMore && !_hasMore) {
      return;
    }

    if (!loadMore && !reset) {
      _currentPage = 1;
      _hasMore = true;
    }

    _isLoading = true;

    if (!loadMore) {
      emit(GetAllUsersLoading());
    }

    try {
      // ✅ **تعديل هنا: طلب البيانات الحالية + التحميل الكامل في نفس الوقت**
      final currentPageFuture = apiService.getUsers(
        page: _currentPage,
        limit: 5,
        stageName: stageFilter,
        duplicates: duplicatesOnly,
        ignoreDuplicates: duplicatesOnly,
      );

      // ✅ **إضافة: تحميل جميع البيانات في الخلفية فوراً دون انتظار**
      Future<void>? loadAllFuture;
      if (!loadMore && _allLeads.isEmpty) {
        loadAllFuture = Future.microtask(() async {
          try {
            final allResponse = await apiService.getUsers(
              page: 1,
              limit: 3000,
              // stageName: stageFilter,
            );
            if (allResponse != null && allResponse.data != null) {
              _allLeads
                ..clear()
                ..addAll(allResponse.data!);
            }
          } catch (e) {
            print('Background load failed: $e');
          }
        });
      }

      // ✅ انتظار البيانات الحالية فقط
      final response = await currentPageFuture;

      if (response != null) {
        final newLeads = response.data ?? [];

        if (!loadMore) {
          _originalLeadsResponse = AllUsersModel(
            data: List.from(newLeads),
            pagination: response.pagination,
            results: response.results,
          );
          leads.clear();
          //  _allLeads.clear();
        }
        _allLeads.addAll(newLeads);
        leads.addAll(newLeads);

        // ✅ **تحسين: تخفيف عمليات الفرز**
        _sortAndExtractNames();

        _currentPage++;
        final totalPages = response.pagination?.numberOfPages ?? 1;
        _hasMore = _currentPage <= totalPages;

        emit(
          GetAllUsersSuccess(
            AllUsersModel(
              results: leads.length,
              pagination: _originalLeadsResponse?.pagination,
              data: leads,
            ),
          ),
        );

        // ✅ **بدء التحميل الخلفي إذا لم يبدأ بعد**
        if (loadAllFuture != null) {
          loadAllFuture.ignore(); // لا ننتظره
        }
      } else {
        if (!loadMore) {
          emit(GetAllUsersFailure('Failed to load users.'));
        }
      }
    } catch (e) {
      if (!loadMore) {
        emit(GetAllUsersFailure(e.toString()));
      }
    } finally {
      _isLoading = false;
    }
  }

  // ✅ **دالة مساعدة للفرز واستخراج الأسماء**
  void _sortAndExtractNames() {
    // الفرز
    leads.sort((a, b) {
      final aDate = DateTime.tryParse(a.date ?? '') ?? DateTime.now();
      final bDate = DateTime.tryParse(b.date ?? '') ?? DateTime.now();
      return bDate.compareTo(aDate);
    });

    // جمع الأسماء
    final salesSet = <String>{};
    final teamLeaderSet = <String>{};

    for (var lead in leads) {
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
  }

  // ✅ دالة مساعدة للتحميل عند السكرول
  Future<void> loadMoreUsers({String? stageFilter}) async {
    await fetchAllUsers(
      stageFilter: stageFilter,
      loadMore: true, // ✅ إشارة أن هذا تحميل للمزيد
    );
  }

  void resetPagination() {
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
    leads.clear();
    emit(GetAllUsersInitial());
  }

  Future<void> fetchStagesStats() async {
    emit(StagesStatsLoading());

    try {
      final response = await apiService.getStageStats();
      if (response != null) {
        emit(StagesStatsSuccess(response));
      } else {
        emit(const StagesStatsFailure("Failed to fetch stages stats"));
      }
    } catch (e) {
      emit(StagesStatsFailure(e.toString()));
    }
  }

  Future<void> fetchLeadsInTrash() async {
    emit(GetLeadsInTrashLoading());
    try {
      final leadsInTrash = await apiService.getLeadsDataInTrash();
      _originalLeadsResponseee = leadsInTrash; // حفظ نسخة من البيانات
      emit(GetLeadsInTrashSuccess(leadsInTrash!));
    } catch (e) {
      emit(
        GetLeadsInTrashFailure(
          ' Failed to fetch leads in trash: ${e.toString()}',
        ),
      );
    }
  }

  // تم دمج فلتر 'name' مع 'query' لتبسيط المناداة على الدالة
  void filterLeadsAdmin({
    String? query,
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
    String? addedBy,
    String? assignedFrom,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastStageUpdateStart,
    DateTime? lastStageUpdateEnd,
    DateTime? lastCommentDateStart,
    DateTime? lastCommentDateEnd,
    String? oldStageName,
    DateTime? oldStageDateStart,
    DateTime? oldStageDateEnd,
    bool duplicatesOnly = false,
  }) {
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

    if (_allLeads.isEmpty) {
      emit(const GetAllUsersFailure("No leads data available for filtering."));
      return;
    }

    List<Lead> filteredLeads = List.from(
      _allLeads,
    ); // ✅ الفلترة على كل البيانات

    // ✅ فلترة الدوبلكيتس
    if (duplicatesOnly) {
      filteredLeads =
          filteredLeads
              .where((lead) => (lead.allVersions?.length ?? 0) > 1)
              .toList();
    }

    // ✅ فلترة بالكويري
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      filteredLeads =
          filteredLeads.where((lead) {
            final matchName = lead.name?.toLowerCase().contains(q) ?? false;
            final matchEmail = lead.email?.toLowerCase().contains(q) ?? false;
            final matchPhone = lead.phone?.contains(q) ?? false;

            final matchInVersions =
                (lead.allVersions?.length ?? 0) > 1
                    ? lead.allVersions!.any((v) {
                      final nameMatch =
                          v.name?.toLowerCase().contains(q) ?? false;
                      final emailMatch =
                          v.email?.toLowerCase().contains(q) ?? false;
                      final phoneMatch = v.phone?.contains(q) ?? false;
                      return nameMatch || emailMatch || phoneMatch;
                    })
                    : false;

            return matchName || matchEmail || matchPhone || matchInVersions;
          }).toList();
    }

    // ✅ باقي الفلاتر
    filteredLeads =
        filteredLeads.where((lead) {
          final matchCountry =
              country == null ||
              (lead.phone != null && lead.phone!.startsWith(country));

          final matchDev =
              developer == null ||
              (lead.project?.developer?.name?.toLowerCase() ==
                  developer.toLowerCase());

          final matchProject =
              project == null ||
              (lead.project?.name?.toLowerCase() == project.toLowerCase());

          final matchStage =
              stage == null ||
              (lead.stage?.name?.toLowerCase() == stage.toLowerCase());

          final matchChannel =
              channel == null ||
              (lead.chanel?.name?.toLowerCase() == channel.toLowerCase());

          final matchSales =
              sales == null ||
              (lead.sales?.name?.toLowerCase() == sales.toLowerCase());

          final matchCommunicationWay =
              communicationWay == null ||
              (lead.communicationway?.name?.toLowerCase() ==
                  communicationWay.toLowerCase());

          final matchCampaign =
              campaign == null ||
              (lead.campaign?.campainName?.toLowerCase() ==
                  campaign.toLowerCase());

          final matchAddedBy =
              addedBy == null ||
              (lead.addby?.name?.toLowerCase() == addedBy.toLowerCase());

          final matchAssignedFrom =
              assignedFrom == null ||
              (lead.leadAssigns?.any(
                    (a) =>
                        a.assignedFrom?.name?.toLowerCase() ==
                        assignedFrom.toLowerCase(),
                  ) ??
                  false);

          final matchAssignedTo =
              assignedTo == null ||
              (lead.leadAssigns?.any(
                    (a) =>
                        a.assignedTo?.name?.toLowerCase() ==
                        assignedTo.toLowerCase(),
                  ) ??
                  false);

          final matchOldStage =
              oldStageName == null ||
              (lead.leadStages?.any(
                    (s) =>
                        s.stage?.name?.toLowerCase() ==
                        oldStageName.toLowerCase(),
                  ) ??
                  false);

          final matchOldStageDate =
              (oldStageDateStart == null && oldStageDateEnd == null) ||
              (lead.leadStages?.any((s) {
                    final oldStageNameMatch =
                        oldStageName == null ||
                        (s.stage?.name?.toLowerCase() ==
                            oldStageName.toLowerCase());
                    final createdAtDate =
                        parseNullableDate(s.createdAt) ??
                        parseNullableDate(s.dateselectedforstage);
                    if (createdAtDate == null) return false;
                    final createdAtOnly = getDateOnly(createdAtDate);
                    final oldStageStartOnly =
                        oldStageDateStart != null
                            ? getDateOnly(oldStageDateStart)
                            : null;
                    final oldStageEndOnly =
                        oldStageDateEnd != null
                            ? getDateOnly(oldStageDateEnd)
                            : null;
                    final matchRange =
                        (oldStageStartOnly == null ||
                            !createdAtOnly.isBefore(oldStageStartOnly)) &&
                        (oldStageEndOnly == null ||
                            !createdAtOnly.isAfter(oldStageEndOnly));
                    return oldStageNameMatch && matchRange;
                  }) ??
                  false);

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

          final lastCommentDate = parseNullableDate(lead.lastcommentdate);
          final lastCommentDateOnly =
              lastCommentDate != null ? getDateOnly(lastCommentDate) : null;
          final lastCommentDateStartOnly =
              lastCommentDateStart != null
                  ? getDateOnly(lastCommentDateStart)
                  : null;
          final lastCommentDateEndOnly =
              lastCommentDateEnd != null
                  ? getDateOnly(lastCommentDateEnd)
                  : null;
          final matchLastCommentDate =
              (lastCommentDateStart == null && lastCommentDateEnd == null) ||
              (lastCommentDateOnly != null &&
                  (lastCommentDateStartOnly == null ||
                      !lastCommentDateOnly.isBefore(
                        lastCommentDateStartOnly,
                      )) &&
                  (lastCommentDateEndOnly == null ||
                      !lastCommentDateOnly.isAfter(lastCommentDateEndOnly)));

          return matchCountry &&
              matchDev &&
              matchProject &&
              matchStage &&
              matchChannel &&
              matchSales &&
              matchCommunicationWay &&
              matchCampaign &&
              matchAddedBy &&
              matchAssignedFrom &&
              matchAssignedTo &&
              matchDateRange &&
              matchLastStageUpdated &&
              matchLastCommentDate &&
              matchOldStage &&
              matchOldStageDate;
        }).toList();

    // ✅ الترتيب النهائي
    if (filteredLeads.isNotEmpty) {
      if (stage != null && stage.isNotEmpty) {
        filteredLeads.sort((a, b) {
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
      } else {
        filteredLeads.sort((a, b) {
          final aDate = parseNullableDate(a.date) ?? DateTime.now();
          final bDate = parseNullableDate(b.date) ?? DateTime.now();
          return bDate.compareTo(aDate);
        });
      }

      emit(GetAllUsersSuccess(AllUsersModel(data: filteredLeads)));
    } else {
      final bool hasActiveFilters =
          query?.isNotEmpty == true ||
          country != null ||
          developer != null ||
          project != null ||
          stage != null ||
          channel != null ||
          sales != null ||
          communicationWay != null ||
          campaign != null;

      if (hasActiveFilters) {
        emit(
          const GetAllUsersFailure("No leads found matching your criteria."),
        );
      } else {
        emit(const GetAllUsersFailure("No leads found."));
      }
    }
  }

  // 🔍 Check if phone number exists in all leads
  bool phoneExists(String phone) {
    final normalized = phone.trim();

    return _allLeads.any(
      (lead) => lead.phone != null && lead.phone!.trim() == normalized,
    );
  }

  // ✅ الخطوة 7: تحديث دالة الفلترة
  // ✅ الكود الكامل والصحيح للدالة
  void filterLeadsAdminForAdvancedSearch({
    String? salesId,
    String? country,
    String? creationDate,
    String? fromDate,
    String? toDate,
    String? user,
    String? commentDate,
  }) {
    if (_originalLeadsResponse == null ||
        _originalLeadsResponse!.data == null) {
      emit(const GetAllUsersFailure("No original data to filter."));
      return;
    }
    List<Lead> filteredLeads = List.from(_allLeads);

    // --- التحويلات تتم مرة واحدة هنا لتجنب التكرار وتحسين الأداء ---
    final DateTime? startDate =
        fromDate != null ? DateTime.tryParse(fromDate) : null;
    final DateTime? endDate = toDate != null ? DateTime.tryParse(toDate) : null;
    final DateTime? creationDateObj =
        creationDate != null ? DateTime.tryParse(creationDate) : null;
    final DateTime? commentDateObj =
        commentDate != null ? DateTime.tryParse(commentDate) : null;
    filteredLeads =
        filteredLeads.where((lead) {
          final matchSales = salesId == null || (lead.sales?.id == salesId);
          final matchUser =
              user == null ||
              (lead.addby?.name?.toLowerCase() == user.toLowerCase());
          final leadPhoneCode =
              lead.phone != null ? getPhoneCodeFromPhone(lead.phone!) : null;
          final matchCountry =
              country == null || (leadPhoneCode?.startsWith(country) ?? false);
          final DateTime? leadCreatedAt =
              lead.createdAt != null
                  ? DateTime.tryParse(lead.createdAt!)
                  : null;
          // --- منطق مقارنة التواريخ المصحح ---
          // 1. فلتر نطاق التاريخ (From/To)
          final matchFromToDate =
              (startDate == null || endDate == null)
                  ? true // إذا كان أحد التواريخ غير موجود، تجاهل هذا الفلتر
                  : (leadCreatedAt != null &&
                      (leadCreatedAt.isAfter(startDate) ||
                          leadCreatedAt.isAtSameMomentAs(startDate)) &&
                      (leadCreatedAt.isBefore(endDate) ||
                          leadCreatedAt.isAtSameMomentAs(endDate)));
          // 2. فلتر تاريخ الإنشاء (يوم واحد)
          final matchCreationDate =
              creationDateObj == null
                  ? true
                  : (leadCreatedAt != null &&
                      leadCreatedAt.isAfter(creationDateObj) &&
                      leadCreatedAt.isBefore(
                        creationDateObj.add(const Duration(days: 1)),
                      )); // البحث خلال 24 ساعة من تاريخ البدء
          // 3. فلتر تاريخ آخر تعليق
          final bool hasValidCommentDate =
              lead.lastcommentdate != null &&
              lead.lastcommentdate != "_" &&
              lead.lastcommentdate!.isNotEmpty;
          final DateTime? leadCommentDate =
              hasValidCommentDate
                  ? DateTime.tryParse(lead.lastcommentdate!)?.toUtc()
                  : null;
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
          // --- دمج كل الفلاتر ---
          return matchSales &&
              matchCountry &&
              matchUser &&
              // يتم دمج فلاتر التاريخ هنا
              (startDate != null ? matchFromToDate : true) &&
              (creationDateObj != null ? matchCreationDate : true) &&
              (commentDateObj != null ? matchCommentDate : true);
        }).toList();

    emit(GetAllUsersSuccess(AllUsersModel(data: filteredLeads)));
  }

  String? getPhoneCodeFromPhone(String phone) {
    String cleanedPhone = phone.replaceAll(RegExp(r'\D'), '');

    if (cleanedPhone.length >= 2) {
      if (cleanedPhone.startsWith('20')) return '20'; // Egypt
      if (cleanedPhone.startsWith('966')) return '966'; // Saudi Arabia
      if (cleanedPhone.startsWith('971')) return '971'; // UAE
    }
    return null;
  }
}
