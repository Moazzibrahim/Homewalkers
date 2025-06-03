import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/data_sources/leads_api_service.dart';
import 'package:homewalkers_app/data/models/leads_model.dart';
part 'get_manager_leads_state.dart';

class GetManagerLeadsCubit extends Cubit<GetManagerLeadsState> {
  final GetLeadsService _getLeadsService;
  LeadResponse? _originalLeadsResponse; // 🟡 حفظ البيانات الأصلية
  Map<String, int> _salesLeadCount = {};
  Map<String, int> get salesLeadCount => _salesLeadCount;
  GetManagerLeadsCubit(this._getLeadsService) : super(GetManagerLeadsInitial());

  Future<void> getLeadsByManager() async {
    emit(GetManagerLeadsLoading());

    try {
      final leadsResponse = await _getLeadsService.getLeadsDataByManager();
      _originalLeadsResponse = leadsResponse; // 🟡 حفظ البيانات الأصلية
      // تحميل عدد الـ leads لكل مرحلة
      _salesLeadCount = await _getLeadsService.getLeadCountPerStageInManager();
      log("✅ تم جلب البيانات بنجاح.");
      emit(GetManagerLeadsSuccess(leadsResponse));
    } catch (e) {
      log('❌ خطأ في getLeadsByManager: $e');
      emit(const GetManagerLeadsFailure(" error in loading leads."));
    }
  }

  void filterLeadsByNameInManager(String query) {
    if (_originalLeadsResponse == null) return;

    final filtered =
        _originalLeadsResponse!.data!
            .where(
              (lead) =>
                  lead.name != null &&
                  lead.name!.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    emit(GetManagerLeadsSuccess(LeadResponse(data: filtered)));
  }

  void filterLeadsByStageInManager(String query) {
    if (_originalLeadsResponse?.data == null) return;
    if (query.isEmpty) {
      emit(GetManagerLeadsSuccess(_originalLeadsResponse!));
      return;
    }
    final filtered =
        _originalLeadsResponse!.data!
            .where(
              (lead) =>
                  lead.stage?.name != null &&
                  lead.stage!.name!.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
    emit(GetManagerLeadsSuccess(LeadResponse(data: filtered)));
  }

  void filterLeadsManager({
    String? name,
    String? email,
    String? phone,
    String? country,
    String? developer,
    String? project,
    String? stage,
    String? query,
  }) {
    if (_originalLeadsResponse == null ||
        _originalLeadsResponse!.data == null) {
      emit(GetManagerLeadsFailure("لا توجد بيانات Leads لفلترتها."));
      return;
    }
    final filtered =
        _originalLeadsResponse!.data!.where((lead) {
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
          final matchStage = stage == null || lead.stage?.name == stage;
          return matchQuery &&
              matchCountry &&
              matchDev &&
              matchProject &&
              matchStage;
        }).toList();
    emit(GetManagerLeadsSuccess(LeadResponse(data: filtered)));
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
}
