// ignore_for_file: unused_local_variable
import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/main.dart';
import 'package:meta/meta.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'get_leads_state.dart';

class GetLeadsCubit extends Cubit<GetLeadsState> {
  final GetLeadsService apiService;
  Timer? _timer;
  LeadResponse? _cachedLeads;
  GetLeadsCubit(this.apiService) : super(GetLeadsInitial()) {
    fetchLeads(showLoading: true); // تحميل أولي مع شريط تحميل
    _startPolling(); // تحديث كل دقيقتين بدون شريط تحميل
  }
  void _startPolling() {
    _timer = Timer.periodic(Duration(minutes: 1), (_) {
      fetchLeads(showLoading: false);
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel(); // إلغاء التايمر عند التخلص من Cubit
    return super.close();
  }

  Future<void> fetchLeads({bool showLoading = true}) async {
    if (showLoading) emit(GetLeadsLoading());
    try {
      final data = await apiService.getAssignedData();

      // ترتيب الـ leads من الأحدث إلى الأقدم
      data.data?.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime.now();
        final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime.now();
        return bDate.compareTo(aDate); // الحديث قبل القديم
      });

      _cachedLeads = data;
      final prefs = await SharedPreferences.getInstance();
      final String? teamleaderId = data.data?.first.sales?.teamleader?.id;
      final String? salesId = data.data?.first.sales?.id;
      await prefs.setString("salesIDD", salesId ?? '');
      await prefs.setString('teamLeaderId', teamleaderId ?? '');

      final lastCount = prefs.getInt('lastLeadCount') ?? 0;
      final newCount = data.count ?? 0;

      if (newCount > lastCount) {
        await prefs.setInt('lastLeadCount', newCount);

        // إشعار محلي
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
        // ********* إضافة تخزين في Firestore *********
        final firestore = FirebaseFirestore.instance;
        // لو عايز تخزن كل الـ leads الجديدة
        final newLeads = data.data?.take(newCount - lastCount);
        if (newLeads != null) {
          for (var lead in newLeads) {
            // ممكن تستخدم معرف الـ lead أو أي ID فريد
            final docId = lead.id ?? firestore.collection('leads').doc().id;
            await firestore.collection('leads').doc(docId).set({
              'name': lead.name ?? '',
              'phone': lead.phone ?? '',
              'project': lead.project?.name ?? '',
              'developer': lead.project?.developer?.name ?? '',
              'stage': lead.stage?.name ?? '',
              'sales_teamleader_id': teamleaderId ?? '',
              'assigned_at': DateTime.now(), // وقت التعيين
              // أضف حقول أخرى مهمة حسب الحاجة
            });
          }
        }
      }
      emit(GetLeadsSuccess(data));
    } catch (e) {
      emit(GetLeadsError("No Leads Data Found"));
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
    if (_cachedLeads == null || _cachedLeads!.data == null) {
      emit(GetLeadsError("لا توجد بيانات Leads لفلترتها."));
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
    if (_cachedLeads == null || _cachedLeads!.data == null) {
      emit(GetLeadsError("لا توجد بيانات Leads لفلترتها."));
      return;
    }

    final filtered =
        _cachedLeads!.data!
            .where(
              (lead) =>
                  lead.stage?.name != null &&
                  lead.stage!.name!.toLowerCase() == stageName.toLowerCase(),
            )
            .toList();

    emit(GetLeadsSuccess(LeadResponse(data: filtered)));
  }
}
