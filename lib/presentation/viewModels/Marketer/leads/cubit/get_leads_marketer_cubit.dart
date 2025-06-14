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
      _originalLeadsResponse = leadsResponse; // 🟡 حفظ البيانات الأصلية
      final prefs = await SharedPreferences.getInstance();
      // ⬇️ استخراج الأسماء الحقيقية
      final salesSet = <String>{};
      final teamLeaderSet = <String>{};

      salesNames = salesSet.toList();
      teamLeaderNames = teamLeaderSet.toList();
      log("✅ تم جلب البيانات بنجاح.");
      emit(GetLeadsMarketerSuccess(leadsResponse));
    } catch (e) {
      log('❌ خطأ في getLeadsByManager: $e');
      emit(const GetLeadsMarketerFailure(" No leads found"));
    }
  }
}
