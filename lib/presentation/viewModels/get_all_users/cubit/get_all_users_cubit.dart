// ignore_for_file: unused_field, unnecessary_null_comparison
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/models/all_users_model.dart';
import 'package:homewalkers_app/data/data_sources/get_all_users_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
part 'get_all_users_state.dart';

class GetAllUsersCubit extends Cubit<GetAllUsersState> {
  final GetAllUsersApiService apiService;
  AllUsersModel? _originalLeadsResponse;
  LeadResponse? _originalLeadsResponseee;
  final Map<String, int> _salesLeadCount = {};
  Map<String, int> get salesLeadCount => _salesLeadCount;
  List<String> salesNames = [];
  List<String> teamLeaderNames = [];

  GetAllUsersCubit(this.apiService) : super(GetAllUsersInitial());
  Future<void> fetchLeadCounts() async {
    // No need for a loading state here as it runs in the background
    try {
      final response = await apiService.getUsers();

      if (response != null && response.data != null) {
        final Map<String, int> leadCounts = {};

        for (var lead in response.data!) {
          if (lead.sales?.userlog?.id != null) {
            final salesId = lead.sales!.userlog!.id!;
            // Add salesId to map and increment count, or set to 1 if new
            leadCounts[salesId] = (leadCounts[salesId] ?? 0) + 1;
          }
        }
        // Emit success state with the map of counts
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

  Future<void> fetchAllUsers({String? stageFilter}) async {
    emit(GetAllUsersLoading());
    try {
      final response = await apiService.getUsers();
      _originalLeadsResponse = response;

      if (response != null) {
        // ... (your existing logic for salesNames, teamLeaderNames etc.)
        final salesSet = <String>{};
        final teamLeaderSet = <String>{};

        for (var lead in response.data ?? []) {
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

        emit(GetAllUsersSuccess(response));
      } else {
        emit(GetAllUsersFailure('Failed to fetch users.'));
      }
    } catch (e) {
      emit(GetAllUsersFailure('An error occurred: ${e.toString()}'));
    }
  }

  Future<void> fetchLeadsInTrash() async {
    emit(GetLeadsInTrashLoading());
    try {
      final leadsInTrash = await apiService.getLeadsDataInTrash();
      _originalLeadsResponseee = leadsInTrash; // حفظ نسخة من البيانات
      emit(GetLeadsInTrashSuccess(leadsInTrash));
    } catch (e) {
      emit(
        GetLeadsInTrashFailure(
          ' Failed to fetch leads in trash: ${e.toString()}',
        ),
      );
    }
  }

  void filterLeadsAdmin({
    String? name, // 🟡 هذا الباراميتر هو نفسه 'query' لو بحثت بالاسم فقط
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
    String? query, // 🟡 نص البحث العام من TextField
  }) {
    if (_originalLeadsResponse == null ||
        _originalLeadsResponse!.data == null) {
      emit(
        const GetAllUsersFailure("No leads data available for filtering."),
      ); // رسالة أوضح
      return;
    }
    // ابدأ دائمًا من البيانات الأصلية غير المُفلترة
    List<Lead> filteredLeads = List.from(_originalLeadsResponse!.data!);
    // 1. تطبيق الفلترة النصية (query) أولاً
    // هذا الـ 'query' يمثل نص البحث العام من TextField (اسم، إيميل، هاتف)
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      filteredLeads =
          filteredLeads.where((lead) {
            final matchName = lead.name?.toLowerCase().contains(q) ?? false;
            final matchEmail = lead.email?.toLowerCase().contains(q) ?? false;
            final matchPhone = lead.phone?.contains(q) ?? false;
            return matchName || matchEmail || matchPhone;
          }).toList();
    }
    // 2. تطبيق الفلترة بالـ 'name' (إذا تم إرساله من الـ dialog كبحث بالاسم فقط)
    // هذا يمكن دمجه مع الـ 'query' إذا كان البحث العام يغطي الاسم.
    // لكن إذا كنت تريد البحث بالاسم فقط من الـ dialog بشكل منفصل عن الـ query العام:
    if (name != null && name.isNotEmpty) {
      final n = name.toLowerCase();
      filteredLeads =
          filteredLeads
              .where((lead) => lead.name?.toLowerCase().contains(n) ?? false)
              .toList();
    }
    // 3. تطبيق باقي الفلاتر بناءً على البيانات المُفلترة من الخطوات السابقة
    filteredLeads =
        filteredLeads.where((lead) {
          final leadPhoneCode =
              lead.phone != null ? getPhoneCodeFromPhone(lead.phone!) : null;

          final matchCountry =
              country == null ||
              (leadPhoneCode != null && leadPhoneCode.startsWith(country));
          final matchDev =
              developer == null ||
              (lead.project?.developer?.name?.toLowerCase() ==
                  developer.toLowerCase());
          final matchProject =
              project == null ||
              (lead.project?.name?.toLowerCase() == project.toLowerCase());
          final matchChannel =
              channel == null ||
              (lead.chanel?.name?.toLowerCase() == channel.toLowerCase());
          final matchStage =
              stage == null ||
              (lead.stage?.name?.toLowerCase() == stage.toLowerCase());
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
          return matchCountry &&
              matchDev &&
              matchProject &&
              matchStage &&
              matchChannel &&
              matchSales &&
              matchCommunicationWay &&
              matchCampaign;
        }).toList();
    if (filteredLeads.isEmpty &&
        ((query != null && query.isNotEmpty) ||
            (name != null && name.isNotEmpty) || // إذا كان name منفصل عن query
            country != null ||
            developer != null ||
            project != null ||
            stage != null ||
            channel != null ||
            sales != null ||
            communicationWay != null ||
            campaign != null)) {
      emit(
        const GetAllUsersFailure("No leads found matching your criteria."),
      ); // رسالة أوضح
    } else if (filteredLeads.isEmpty) {
      // إذا كانت القائمة فارغة ولكن لا توجد فلاتر مطبقة، فهذا يعني لا توجد بيانات من الأساس
      emit(const GetAllUsersFailure("No leads found."));
    } else {
      emit(GetAllUsersSuccess(AllUsersModel(data: filteredLeads)));
    }
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

    List<Lead> filteredLeads = List.from(_originalLeadsResponse!.data!);

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
          final DateTime? leadCommentDate =
              lead.lastcommentdate != null
                  ? DateTime.tryParse(lead.lastcommentdate!)
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
          final matchCommentDate =
              commentDateObj == null
                  ? true
                  : (leadCommentDate != null && 
                      (leadCommentDate.isAtSameMomentAs(commentDateObj) ||
                          leadCommentDate.isAfter(commentDateObj)) &&
                      (leadCommentDate.isBefore(
                            commentDateObj.add(const Duration(days: 1)),) ||
                          leadCommentDate.isAtSameMomentAs(
                            commentDateObj.add(const Duration(days: 1)),
                          )));
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
}
