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
    emit(GetLeadsInTrashFailure('حدث خطأ أثناء تحميل البيانات المحذوفة'));
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
              (lead.campaign?.campainName?.toLowerCase() == campaign.toLowerCase());
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
  void filterLeadsAdminForAdvancedSearch({
    String? salesId, // <-- استخدام الـ ID
    String? country,
    String? creationDate,
    String? fromDate,
    String? toDate,
    String? user,
    String? commentDate,
  }) {
    if (_originalLeadsResponse == null || _originalLeadsResponse!.data == null) {
      emit(const GetAllUsersFailure("No original data to filter. Please fetch users first."));
      return;
    }

    List<Lead> filteredLeads = List.from(_originalLeadsResponse!.data!);

    filteredLeads = filteredLeads.where((lead) {
      // <-- مقارنة باستخدام الـ ID
      final matchSales = salesId == null || (lead.sales?.id == salesId);

      final leadPhoneCode = lead.phone != null ? getPhoneCodeFromPhone(lead.phone!) : null;
      final matchCountry = country == null || (leadPhoneCode?.startsWith(country) ?? false);
      final matchUser = user == null || (lead.addby?.name?.toLowerCase() == user.toLowerCase());
      final leadCreatedAt = lead.createdAt != null ? DateTime.tryParse(lead.createdAt!) : null;
      final leadCommentDate = lead.lastcommentdate != null ? DateTime.tryParse(lead.lastcommentdate!) : null;

      final matchCreationDate = creationDate == null ||
          (leadCreatedAt != null && _compareOnlyDate(leadCreatedAt, DateTime.parse(creationDate)));

      final matchFromToDate = (fromDate == null && toDate == null) ||
          (leadCreatedAt != null &&
              (fromDate == null || leadCreatedAt.isAfter(DateTime.parse(fromDate).subtract(const Duration(days: 1)))) &&
              (toDate == null || leadCreatedAt.isBefore(DateTime.parse(toDate).add(const Duration(days: 1)))));
      
      final matchCommentDate = commentDate == null ||
          (leadCommentDate != null && _compareOnlyDate(leadCommentDate, DateTime.parse(commentDate)));

      return matchSales &&
          matchCountry &&
          matchCreationDate &&
          matchFromToDate &&
          matchUser &&
          matchCommentDate;
    }).toList();
    
    // ملاحظة: لا داعي لإصدار حالة فشل إذا كانت النتائج فارغة، بل حالة نجاح مع قائمة فارغة
    // الواجهة ستتعامل مع عرض رسالة "لا توجد نتائج"
    emit(GetAllUsersSuccess(AllUsersModel(data: filteredLeads)));
  }

  bool _compareOnlyDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
