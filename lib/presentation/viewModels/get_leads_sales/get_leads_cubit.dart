// ignore_for_file: unused_local_variable
import 'dart:async';
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
  LeadResponse? _cachedLeads; // لتخزين البيانات داخليًا
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
      _cachedLeads = data;
      final prefs = await SharedPreferences.getInstance();
      final String? teamleaderId = data.data?.first.sales?.teamleader?.id;
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
    String? country, // هنا country هو كود الدولة، مثال: "20"
    String? developer,
    String? project,
    String? stage,
  }) {
    if (_cachedLeads == null || _cachedLeads!.data == null) {
      emit(GetLeadsError("لا توجد بيانات Leads لفلترتها."));
      return;
    }
    final filtered =
        _cachedLeads!.data!.where((lead) {
          final matchName =
              name == null ||
              (lead.name?.toLowerCase().contains(name.toLowerCase()) ?? false);
          final leadPhoneCode =
              lead.phone != null ? getPhoneCodeFromPhone(lead.phone!) : null;
          final matchCountry =
              country == null || leadPhoneCode?.startsWith(country) == true;
          final matchDev =
              developer == null || lead.project?.developer?.name == developer;
          final matchProject = project == null || lead.project?.name == project;
          final matchStage = stage == null || lead.stage?.name == stage;
          return matchName &&
              matchCountry &&
              matchDev &&
              matchProject &&
              matchStage;
        }).toList();
    emit(GetLeadsSuccess(LeadResponse(data: filtered)));
  }
}
