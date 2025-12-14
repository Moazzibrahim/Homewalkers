// get_leads_marketer_cubit.dart
// ignore_for_file: unused_field, unused_local_variable, avoid_print
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
  List<LeadData> leads = []; // 🟢 الليست الجديدة اللي طلبتها

  GetLeadsMarketerCubit(this._getLeadsService)
    : super(GetLeadsMarketerInitial());

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
      emit(GetLeadsMarketerSuccess(LeadResponse(data: filteredData)));
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
    print("Sales param: '$sales'");
    print("Sales length: ${sales?.length}");

    // البداية من البيانات الأصلية
    List<LeadData> filteredLeads = List.from(_originalLeadsResponse!.data!);
    print("Initial leads count: ${filteredLeads.length}");
    print("filtered list: ${filteredLeads}");

    // 1️⃣ فلترة query
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
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
    }

    // 2️⃣ فلترة name
    if (name != null && name.isNotEmpty) {
      final n = name.toLowerCase();
      filteredLeads =
          filteredLeads
              .where((lead) => lead.name?.toLowerCase().contains(n) ?? false)
              .toList();
    }

    // 3️⃣ باقي الفلاتر
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

          // ✅ فلترة الـ sales مع trim و lowerCase
          final matchSales =
              sales == null
                  ? true
                  : (lead.sales != null &&
                      lead.sales!.name != null &&
                      lead.sales!.name!.trim().toLowerCase() ==
                          sales.trim().toLowerCase());

          if (!matchSales) {
            print(
              "❌ Lead '${lead.name}' failed sales filter. Lead sales: '${lead.sales?.name}' | Filter sales: '$sales'",
            );
          } else {
            print(
              "✅ Lead '${lead.name}' passed sales filter. Lead sales: '${lead.sales?.name}'",
            );
          }

          final matchCommunicationWay =
              communicationWay == null ||
              (lead.communicationway?.name?.toLowerCase() ==
                  communicationWay.toLowerCase());
          final matchCampaign =
              campaign == null ||
              (lead.campaign?.name?.toLowerCase() == campaign.toLowerCase());

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

    print("Filtered leads count after all filters: ${filteredLeads.length}");
    if (filteredLeads.isNotEmpty) {
      print("=== FILTER END ===  : ${filteredLeads.first.name}");
    } else {
      print("=== FILTER END ===  : No leads found");
    }

    if (filteredLeads.isEmpty) {
      emit(GetLeadsMarketerFailure("No leads found matching your criteria."));
    } else {
      emit(GetLeadsMarketerSuccess(LeadResponse(data: filteredLeads)));
      print("🟢 Emit leads count=${filteredLeads.length}");
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
