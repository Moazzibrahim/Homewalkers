// assign_cubit.dart
// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/assign_lead/assign_lead_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssignleadCubit extends Cubit<AssignState> {
  AssignleadCubit() : super(AssignInitial());

  Future<void> putAssignUser({
    required List<String> leadId,
    required String lastDateAssign,
  }) async {
    emit(AssignLoading());

    final dio = Dio();
    final String url = '${Constants.baseUrl}/users/$leadId';

    final prefs = await SharedPreferences.getInstance();
    final salesId = prefs.getString('saved_id');

    final body = {
      "assign": "true",
      "lastdateassign": lastDateAssign,
      "sales": salesId,
    };
    try {
      final response = await dio.put(url, data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("date: $lastDateAssign");
        emit(AssignSuccess());
      } else {
        emit(AssignFailure('Unexpected status: ${response.statusCode}'));
      }
    } catch (e) {
      emit(AssignFailure(e.toString()));
    }
  }
}
