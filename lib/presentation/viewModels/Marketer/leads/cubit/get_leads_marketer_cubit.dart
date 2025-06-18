// get_leads_marketer_cubit.dart

// ignore_for_file: unused_field, unused_local_variable

import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'get_leads_marketer_state.dart';

class GetLeadsMarketerCubit extends Cubit<GetLeadsMarketerState> {
  final GetLeadsService _getLeadsService;
  LeadResponse? _originalLeadsResponse; // 🟡 حفظ البيانات الأصلية
  final Map<String, int> _salesLeadCount = {};
  Map<String, int> get salesLeadCount => _salesLeadCount;
  List<String> salesNames = [];
  List<String> teamLeaderNames = [];

  GetLeadsMarketerCubit(this._getLeadsService)
    : super(GetLeadsMarketerInitial());

  Future<void> getLeadsByMarketer() async {
    emit(GetLeadsMarketerLoading());
    try {
      final leadsResponse = await _getLeadsService.getLeadsDataByMarketer();
      _originalLeadsResponse = leadsResponse; // 🟡 حفظ البيانات الأصلية هنا
      final prefs = await SharedPreferences.getInstance();
      final managerName = prefs.getString("markterName");
      // ⬇️ استخراج الأسماء الحقيقية
      final salesSet = <String>{};
      final teamLeaderSet = <String>{};

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
      log("✅ تم جلب البيانات بنجاح.");
      emit(GetLeadsMarketerSuccess(leadsResponse));
    } catch (e) {
      log('❌ خطأ في getLeadsByMarketer: $e');
      emit(
        const GetLeadsMarketerFailure("Failed to load leads."),
      ); // رسالة أوضح
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
      emit(GetLeadsMarketerSuccess(leadsResponse));
    } catch (e) {
      log('❌ خطأ في getLeadsByMarketerInTrash: $e');
      emit(
        const GetLeadsMarketerFailure("No leads found in trash."),
      ); // رسالة أوضح
    }
  }

  // ❌ حذف الدالة دي، لأن filterLeadsMarketer هتكون شاملة
  // void filterLeadsByStageInMarketer(String query) {
  //   if (_originalLeadsResponse?.data == null) return;
  //   if (query.isEmpty) {
  //     emit(GetLeadsMarketerSuccess(_originalLeadsResponse!));
  //     return;
  //   }
  //   final filtered =
  //       _originalLeadsResponse!.data!
  //           .where(
  //             (lead) =>
  //                 lead.stage?.name != null &&
  //                 lead.stage!.name!.toLowerCase().contains(query.toLowerCase()),
  //           )
  //           .toList();
  //   emit(GetLeadsMarketerSuccess(LeadResponse(data: filtered)));
  // }

  void filterLeadsMarketer({
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
        const GetLeadsMarketerFailure("No leads data available for filtering."),
      ); // رسالة أوضح
      return;
    }

    // ابدأ دائمًا من البيانات الأصلية غير المُفلترة
    List<LeadData> filteredLeads = List.from(_originalLeadsResponse!.data!);

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
              (lead.campaign?.name?.toLowerCase() == campaign.toLowerCase());

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
        const GetLeadsMarketerFailure("No leads found matching your criteria."),
      ); // رسالة أوضح
    } else if (filteredLeads.isEmpty) {
      // إذا كانت القائمة فارغة ولكن لا توجد فلاتر مطبقة، فهذا يعني لا توجد بيانات من الأساس
      emit(const GetLeadsMarketerFailure("No leads found."));
    } else {
      emit(GetLeadsMarketerSuccess(LeadResponse(data: filteredLeads)));
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
}
