// assign_cubit.dart
// ignore_for_file: avoid_print
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:homewalkers_app/core/constants/constants.dart';
import 'package:homewalkers_app/presentation/viewModels/sales/assign_lead/assign_lead_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssignleadCubit extends Cubit<AssignState> {
  AssignleadCubit() : super(AssignInitial());
  Future<void> assignUserAndLead({
    required List<String> leadIds,
    required String dateAssigned,
    required String lastDateAssign,
    required String teamleadersId,
  }) async {
    emit(AssignLoading());

    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final salesId = prefs.getString('salesId');

    if (salesId == null) {
      emit(
        AssignFailure('Missing salesId or teamLeaderId from SharedPreferences'),
      );
      return;
    }

    try {
      for (String leadId in leadIds) {
        // First PUT to /users/{id}
        final putUrl = '${Constants.baseUrl}/users/$leadId';
        final putBody = {
          "assign": "true",
          "lastdateassign": lastDateAssign,
          "sales": teamleadersId,
        };

        final putResponse = await dio.put(putUrl, data: putBody);
        if (putResponse.statusCode != 200 && putResponse.statusCode != 201) {
          emit(AssignFailure('Failed to assign lead in PUT: $leadId'));
          return;
        }

        // Then POST to /LeadAssigned
        final postUrl = '${Constants.baseUrl}/LeadAssigned';
        final postBody = {
          "LeadId": leadId,
          "date_Assigned": dateAssigned,
          "Assigned_From": salesId,
          "Assigned_to": teamleadersId,
        };

        final postResponse = await dio.post(
          postUrl,
          data: postBody,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );
        if (postResponse.statusCode != 200 && postResponse.statusCode != 201) {
          emit(AssignFailure('Failed to assign lead in POST: $leadId'));
          return;
        }
      }
      // If all requests are successful, emit success state
      log('All leads assigned successfully');
      log("teamleadersId: $teamleadersId");
      log("salesId: $salesId");
      emit(AssignSuccess());
    } catch (e) {
      emit(AssignFailure('❌ Error during combined assignment: $e'));
    }
  }

  Future<void> assignUserAndLeadTeamLeader({
    required List<String> leadIds,
    required String dateAssigned,
    required String lastDateAssign,
    required String teamleadersId,
    required String salesId,
    bool? clearhistory,
  }) async {
    emit(AssignLoading());

    final dio = Dio();

    try {
      for (String leadId in leadIds) {
        // First PUT to /users/{id}
        final putUrl = '${Constants.baseUrl}/users/$leadId';
        final putBody = {
          "assign": "true",
          "lastdateassign": lastDateAssign,
          "sales": salesId,
        };
        final putResponse = await dio.put(putUrl, data: putBody);
        if (putResponse.statusCode != 200 && putResponse.statusCode != 201) {
          emit(AssignFailure('Failed to assign lead in PUT: $leadId'));
          return;
        }
        // Then POST to /LeadAssigned
        final postUrl = '${Constants.baseUrl}/LeadAssigned';
        final postBody = {
          "LeadId": leadId,
          "date_Assigned": dateAssigned,
          "Assigned_From": teamleadersId,
          "Assigned_to": salesId,
          "clearHistory": clearhistory,
        };

        final postResponse = await dio.post(
          postUrl,
          data: postBody,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('clearHistory', clearhistory!);
        if (postResponse.statusCode != 200 && postResponse.statusCode != 201) {
          emit(AssignFailure('Failed to assign lead in POST: $leadId'));
          return;
        }
      }
      // If all requests are successful, emit success state
      log('All leads assigned successfully');
      log("teamleadersId: $teamleadersId");
      log("salesId: $salesId");
      log("clearhistory: $clearhistory");
      emit(AssignSuccess());
    } catch (e) {
      emit(AssignFailure('❌ Error during combined assignment: $e'));
    }
  }

  Future<void> assignLeadFromManager({
    required List<String> leadIds,
    required String dateAssigned,
    required String lastDateAssign,
    required String salesId,
    bool? isClearhistory,
  }) async {
    emit(AssignLoading());

    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final managerId = prefs.getString('managerIdspecific');

    try {
      for (String leadId in leadIds) {
        // First PUT to /users/{id}
        final putUrl = '${Constants.baseUrl}/users/$leadId';
        final putBody = {
          "assign": "true",
          "lastdateassign": lastDateAssign,
          "sales": salesId,
        };
        final putResponse = await dio.put(putUrl, data: putBody);
        if (putResponse.statusCode != 200 && putResponse.statusCode != 201) {
          emit(AssignFailure('Failed to assign lead in PUT: $leadId'));
          return;
        }
        // Then POST to /LeadAssigned
        final postUrl = '${Constants.baseUrl}/LeadAssigned';
        final postBody = {
          "LeadId": leadId,
          "date_Assigned": dateAssigned,
          "Assigned_From": managerId,
          "Assigned_to": salesId,
          "clearHistory": isClearhistory,
        };

        final postResponse = await dio.post(
          postUrl,
          data: postBody,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );
        if (postResponse.statusCode != 200 && postResponse.statusCode != 201) {
          emit(AssignFailure('Failed to assign lead in POST: $leadId'));
          return;
        }
      }
      // If all requests are successful, emit success state
      log('All leads assigned successfully');
      log("manager id: $managerId");
      log("salesId: $salesId");
      emit(AssignSuccess());
    } catch (e) {
      emit(AssignFailure('❌ Error during combined assignment: $e'));
    }
  }
}
