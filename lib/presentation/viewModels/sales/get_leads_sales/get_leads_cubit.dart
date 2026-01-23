// ignore_for_file: unused_local_variable, unused_field
import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/main.dart';
import 'package:meta/meta.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'get_leads_state.dart';

class GetLeadsCubit extends Cubit<GetLeadsState> {
  final GetLeadsService apiService;
  Timer? _timer;
  LeadResponse? _cachedLeads;
  int currentPage = 1;
  final int limit = 500;
  bool hasMore = true;
  bool _isDashboardMode = false; // ⚠️ لتتبع الوضع
  bool _isLoading = false;
  final List<LeadData> _allLeads = [];
  bool get isLoading => _isLoading;
  bool get cachedLeadsHasData =>
      _cachedLeads != null &&
      _cachedLeads!.data != null &&
      _cachedLeads!.data!.isNotEmpty;
  bool _hasFilteredStage = false;

  GetLeadsCubit(this.apiService) : super(GetLeadsInitial()) {
    // ⚠️ لا تجلب بيانات تلقائياً، دع الشاشة تحدد ماذا تريد
    //  _startPolling();
  }

  // void _startPolling() {
  //   _timer = Timer.periodic(const Duration(minutes: 1), (_) {
  //     // ⚠️ تحديث حسب الوضع الحالي
  //     if (_isDashboardMode && _cachedLeads != null) {
  //       fetchDashboardLeads(showLoading: false);
  //     } else if (!_isDashboardMode && _cachedLeads != null) {
  //       fetchLeads(showLoading: false);
  //     }
  //   });
  // }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> fetchDashboardLeads({bool showLoading = true}) async {
    _isDashboardMode = true; // ⚠️ وضع dashboard

    if (showLoading) {
      emit(GetLeadsLoading());
    }

    try {
      // ⚠️ لا تمسح _cachedLeads هنا، دع الخدمة تعيد البيانات كاملة
      final data = await apiService.getAssignedData(
        page: 1,
        limit: 9999,
        forDashboard: true,
      );

      _cachedLeads = data; // ⚠️ تحديث الكاش

      // تحديث الإشعارات
      await _updateNotifications(_cachedLeads!);

      emit(GetLeadsSuccess(_cachedLeads!));
    } catch (e) {
      emit(GetLeadsError("Failed to load dashboard data"));
    }
  }

  Future<void> fetchLeads({
    bool showLoading = true,
    bool loadMore = false,
    bool forDashboard = false,
  }) async {
    _isDashboardMode = false;
    if (_isLoading) return;

    if (showLoading && !loadMore) emit(GetLeadsLoading());

    try {
      currentPage = loadMore ? currentPage + 1 : 1;
      if (!loadMore) _allLeads.clear();

      _isLoading = true;

      final data = await apiService.getAssignedData(
        page: currentPage,
        limit: forDashboard ? 9999 : limit,
        forDashboard: forDashboard,
      );

      if (!loadMore) {
        _cachedLeads = data;
        _allLeads.addAll(data.data ?? []);
      } else {
        _cachedLeads?.data?.addAll(data.data ?? []);
        _allLeads.addAll(data.data ?? []);
      }

      hasMore = (data.data?.isNotEmpty ?? false);

      emit(GetLeadsSuccess(_cachedLeads!));
    } catch (e) {
      emit(GetLeadsError("No Leads Data Found"));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _updateNotifications(LeadResponse leadsResponse) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (leadsResponse.data != null && leadsResponse.data!.isNotEmpty) {
        final String? teamleaderId =
            leadsResponse.data!.first.sales?.teamleader?.id;
        final String? salesId = leadsResponse.data!.first.sales?.id;

        await prefs.setString("salesIDD", salesId ?? '');
        await prefs.setString('teamLeaderId', teamleaderId ?? '');
      }

      final lastCount = prefs.getInt('lastLeadCount') ?? 0;
      final newCount = leadsResponse.count ?? 0;

      if (newCount > lastCount) {
        await prefs.setInt('lastLeadCount', newCount.toInt());

        flutterLocalNotificationsPlugin.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          '📥 Lead جديد',
          '${newCount - lastCount} عميل جديد تم تعيينه لك!',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    } catch (e) {
      log("Error updating notifications: $e");
    }
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

  void filterLeads({
    String? name,
    String? email,
    String? phone,
    String? country,
    String? developer,
    String? project,
    String? stage,
    String? channel,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastStageUpdateStart,
    DateTime? lastStageUpdateEnd,
  }) {
    // if (_cachedLeads == null || _cachedLeads!.data == null) {
    //   emit(GetLeadsError("لا توجد بيانات Leads لفلترتها."));
    //   return;
    // }
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
        _cachedLeads!.data!.where((lead) {
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
          final lastStageUpdated = parseNullableDate(lead.stagedateupdated);
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
              matchChannel &&
              matchDateRange &&
              matchLastStageUpdated &&
              matchStage;
        }).toList();
    emit(GetLeadsSuccess(LeadResponse(data: filtered)));
  }

  Future<void> getLeadStageCountsForSales() async {
    try {
      final stageCounts = await apiService.getLeadCountPerStageInSales();
      log("✅ Stage counts for sales: $stageCounts");
      // تقدر تستخدم emit هنا لو عايز تعرض النتيجة في الواجهة
      emit(GetStageCountSuccess(stageCounts));
    } catch (e) {
      log("❌ Failed to get stage counts for sales: $e");
    }
  }

  void filterLeadsByStageName(String stageName) {
    // if (_cachedLeads == null || _cachedLeads!.data == null) {
    //   emit(GetLeadsError("لا توجد بيانات Leads لفلترتها."));
    //   return;
    // }

    final filtered =
        _cachedLeads!.data!
            .where(
              (lead) =>
                  lead.stage?.name != null &&
                  lead.stage!.name!.toLowerCase() == stageName.toLowerCase(),
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

      // مقارنة مباشرة من القديم إلى الجديد
      return dateA.compareTo(dateB); // الأقدم أولاً، الأحدث بعده
    });
    _cachedLeads = LeadResponse(count: filtered.length, data: filtered);

    emit(GetLeadsSuccess(_cachedLeads!));
  }

  void filterLeadsByStageNameOnce(String stageName) {
    if (_hasFilteredStage) return; // ✅ منع الفلترة المتكررة
    if (_cachedLeads == null || _cachedLeads!.data == null) return;

    _hasFilteredStage = true; // تعليم أن الفلترة حصلت
    filterLeadsByStageName(stageName); // استدعاء الفلترة العادية
  }
}
